class Importer

  attr_reader :user
  def initialize(user)
    @user = user
  end

  def import_events
    # most of the integer timestamps are stored as seconds since Jan 1, 2001!
    beginning_of_time = Date.parse("Jan 1 2001 UTC").beginning_of_day - 9.hours

    # TODO store team id in user model
    team_id = '5699535384870912'

    response = HTTParty.get "http://www.ultianalytics.com/rest/view/team/#{team_id}/gamesdata"
    games = JSON.parse response.body
    action_types = {}
    for game in games
      tournament = game['tournamentName']
      opponent = game['opponentName']
      game_id = game['gameId']
      our_final_score = game['ours']
      their_final_score = game['theirs']
      #game_start_time = epoch + (game['msSinceEpoch']/1000).seconds
      #puts "Game start time:  #{game_start_time} - #{opponent}"

      points = JSON.parse game['pointsJson']

      game_start_time = 1.year.from_now
      game_end_time = 10.years.ago

      for point in points
        our_score = point['summary']['score']['ours']
        their_score = point['summary']['score']['theirs']
        point_start_time = beginning_of_time + point['startSeconds'].seconds
        point_end_time = beginning_of_time + point['endSeconds'].seconds
        line_type = point['summary']['lineType']

        # Games don't have end times, and I don't trust their start times,
        # so we'l just track the earliest and latest point times we see and use that
        game_start_time = point_start_time if game_start_time > point_start_time
        game_end_time = point_end_time if game_end_time < point_end_time


        user.events.create title: "#{tournament} > #{opponent} > #{our_score}-#{their_score}",
                           kind: 'Point', starts_at: point_start_time, ends_at: point_end_time



        for event in point['events']
          action = event['action']
          action_types[action] ||= event
          type = event['type'] # 'Offense' or 'Defense'
          thrower = event['passer']
          receiver = event['receiver']
          defender = event['defender']
          hangtime = event['details']['hangtime'] rescue nil
          event_start_time = beginning_of_time + event['timestamp'].seconds

          # when the other team throws away or scores, we get an event but it's pretty useless
          # the other events don't seem to come in for the other team
          next if ['Throwaway', 'Goal'].include?(action) and type == 'Defense'

          case action
          when 'Catch'
            play = "#{thrower} to #{receiver}"
          when 'Drop'
            play = "Drop by #{receiver}"
          when 'D'
            play = "Block by #{defender}"
          when 'Goal'
            play = "Goal from #{thrower} to #{receiver}"
          when 'Pull'
            play = "Pull by #{defender}"
            play += " (#{hangtime/1000} sec)" if hangtime
          when 'PullOb'
            play = "OB pull by #{defender}"
          when 'Throwaway'
            play = "Throwaway by #{thrower}"
          end

          user.events.create title: "#{tournament} > #{opponent} > #{our_score}-#{their_score} > #{play}",
                             kind: 'Play', starts_at: event_start_time

        end
      end


      # create game event now, cause we finally have start and end times from the points
      user.events.create title: "#{tournament} > #{opponent}", kind: 'Game',
                         starts_at: game_start_time-1.second, ends_at: game_end_time+1.second

    end
    puts "Imported #{user.events.count} events!"
  end

  def import_videos_from_google_drive
    return false if user.token_expired?
    return false unless user.access_token.present?
    session = GoogleDrive.login_with_oauth(user.access_token)
    photos_folder = session.collections.find{|c| c.title == 'Google Photos'}
    scan_folder(photos_folder)
  end

  # recursively open Google Drive collections (folders), imports all files
  def scan_folder(object)
    if object.class == GoogleDrive::Collection
      object.files do |file|
        scan_folder(file)
      end
    elsif object.class == GoogleDrive::File
      unless Video.where(google_id: object.id).exists?
        copy_video(object, user)
      end
    end
  end

  def copy_video(file, user)
    duration = file.api_file.videoMediaMetadata.durationMillis rescue nil

    # assume that if duration is nil, it's not a video
    return if duration.blank?

    #convert duration to seconds
    duration /= 1000

    starts_at = file.api_file.createdDate
    ends_at = starts_at + duration.seconds

    user.videos.create! google_id: file.id,
                        width: file.api_file.videoMediaMetadata.width,
                        height: file.api_file.videoMediaMetadata.height,
                        thumbnail: file.api_file.thumbnailLink,
                        mime_type: file.mime_type,
                        starts_at: starts_at,
                        ends_at: ends_at,
                        duration: duration,
                        title: file.title
  end

  def import_youtube_video_ids
    # TODO store user's channel_id in user model
    youtube_channel_id = 'UCjCcPCvxpSsvHNmgC3SNUZQ'
    # when you ask for all of the user's videos, Youtube seems to return a semi-random 
    # number of results. I've tried this many times. However, if the user has a playlist,
    # then it's always correct. For this reason we're using an "All videos" playlist,
    # which has to be manually added to for all new videos.
    seen_titles = []
    matched_titles = []

    channel = Yt::Channel.new id:  youtube_channel_id
    playlist = channel.playlists.find{|p| p.title.match /all/i }
    for item in playlist.playlist_items
    
      existing_video = Video.find_by_title(item.title)
      seen_titles << item.title
      next unless existing_video

      youtube_id = item.video_id
      thumbnail = item.snippet.thumbnails['high']['url'] rescue nil

      existing_video.update_column :thumbnail, thumbnail if thumbnail
      existing_video.update_column :youtube_id, youtube_id if youtube_id
      matched_titles << item.title
    end

    drive_only_titles = (Video.pluck(:title) - seen_titles).join(', ')
    puts "All seen titles: #{seen_titles.join(', ')}"
    puts "--------------------"
    puts "All matched titles: #{matched_titles.join(', ')}"
    puts "--------------------"
    puts "Youtube-only titles: #{(seen_titles - matched_titles).join(', ')}"
    puts "--------------------"
    puts "Drive-only titles: #{drive_only_titles}"
  end

  def import_youtube_videos
    # TODO store user's channel_id in user model
    youtube_channel_id = 'UCjCcPCvxpSsvHNmgC3SNUZQ'
    # when you ask for all of the user's videos, Youtube seems to return a semi-random 
    # number of results. I've tried this many times. However, if the user has a playlist,
    # then it's always correct. For this reason we're using an "All videos" playlist,
    # which has to be manually managed for all new videos.
    seen_titles = []
    matched_titles = []
    new_titles = []

    channel = Yt::Channel.new id:  youtube_channel_id
    playlist = channel.playlists.find{|p| p.title.match /all/i }
    for item in playlist.playlist_items
      next if item.title == 'Deleted video'
      next if item.title == 'Private video'
    
      seen_titles << item.title
      youtube_id = item.video_id
      thumbnail = item.snippet.thumbnails['high']['url'] rescue nil

      if existing_video = Video.find_by_youtube_id(item.video_id)
        existing_video.update_column :thumbnail, thumbnail if thumbnail != existing_video.thumbnail
        existing_video.update_column :youtube_id, youtube_id if youtube_id != existing_video.youtube_id
        matched_titles << item.title
      else
        new_titles << item.title
        # importing new video via youtube playlist item
        video = Yt::Video.new id: item.video_id
        user.videos.create! youtube_id: item.video_id,
                            thumbnail: thumbnail,
                            duration: video.duration,
                            title: item.title
      end
    end

    puts "All seen titles: #{seen_titles.join(', ')}"
    puts "--------------------"
    puts "All matched titles: #{matched_titles.join(', ')}"
    puts "--------------------"
    puts "All new titles: #{new_titles.join(', ')}"
  end

end
