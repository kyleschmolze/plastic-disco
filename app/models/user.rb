class User < ActiveRecord::Base

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
        user.name = auth['info']['name'] || ""
      end
    end
  end

  def access_token
    oauth_response['credentials']['token'] rescue nil
  end

  def token_expired?
    begin
      Time.now > Time.at(oauth_response['credentials']['expires_at'])
    rescue
      true
    end
  end

  def import_videos
    return false if token_expired?
    return false unless access_token.present?
    session = GoogleDrive.login_with_oauth(access_token)
    photos_folder = session.collections.find{|c| c.title == 'Google Photos'}
    dig(photos_folder)
  end

  # recursively open collections (folders), import files
  def dig(object)
    if object.class == GoogleDrive::Collection
      object.files do |file|
        dig(file)
      end
    elsif object.class == GoogleDrive::File
      unless Video.where(google_id: object.id).exists?
        Video.copy(object, self)
      end
    end
  end

  def self.import_for_user
    # most of the integer timestamps are stored as seconds since Jan 1, 2001!
    beginning_of_time = Date.parse("Jan 1 2001 UTC").beginning_of_day

    response = HTTParty.get 'http://www.ultianalytics.com/rest/view/team/5699535384870912/gamesdata'
    games = JSON.parse response.body
    action_types = []
    for game in games
      tournament = game['tournamentName']
      opponent = game['opponentName']
      game_id = game['gameId']
      our_final_score = game['ours']
      their_final_score = game['theirs']
      game_start_time = Time.at game['msSinceEpoch']/1000
      puts "GAME start time:  #{game_start_time}"

      points = JSON.parse game['pointsJson']

      for point in points
        our_score = point['summary']['score']['ours']
        their_score = point['summary']['score']['theirs']
        duration = point['summary']['elapsedTime']
        start_time = beginning_of_time + point['startSeconds'].seconds
        end_time = beginning_of_time + point['endSeconds'].seconds
        line_type = point['summary']['lineType']
        puts "Point start time: #{start_time}"

        for event in point['events']
          action = event['action']
          action_types << action
          event['type'] # 'Offense' or 'Defense'
          thrower = event['passer']
          receiver = event['receiver']
          start_time = beginning_of_time + event['timestamp'].seconds
          puts "Event start time: #{start_time}"
        end
      end
    end
    puts action_types.uniq
  end


end
