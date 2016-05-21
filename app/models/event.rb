class Event < ActiveRecord::Base

  validates :name, presence: true
  validates :kind, presence: true
  validates :starts_at, presence: true

  before_save :update_video_count

  def videos
    Video.where('starts_at < ? AND ends_at > ?', ends_at||starts_at, starts_at)
  end

  def update_video_count
    self.video_count = videos.count
  end

  # import ALL events for a user (and delete existing ones)
  def self.import_for_user
    Event.delete_all

    # most of the integer timestamps are stored as seconds since Jan 1, 2001!
    beginning_of_time = Date.parse("Jan 1 2001 UTC").beginning_of_day - 9.hours

    response = HTTParty.get 'http://www.ultianalytics.com/rest/view/team/5699535384870912/gamesdata'
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
        duration = point['summary']['elapsedTime']
        point_start_time = beginning_of_time + point['startSeconds'].seconds
        point_end_time = beginning_of_time + point['endSeconds'].seconds
        line_type = point['summary']['lineType']

        # Games don't have end times, and I don't trust their start times,
        # so we'l just track the earliest and latest point times we see and use that
        game_start_time = point_start_time if game_start_time > point_start_time
        game_end_time = point_end_time if game_end_time < point_end_time


        Event.create name: "#{tournament} > #{opponent} > #{our_score}-#{their_score}",
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
            play = "(#{hangtime/1000} sec)" if hangtime
          when 'PullOb'
            play = "OB pull by #{defender}"
          when 'Throwaway'
            play = "Throwaway by #{thrower}"
          end

          Event.create name: "#{tournament} > #{opponent} > #{our_score}-#{their_score} > #{play}",
                       kind: 'Play', starts_at: event_start_time

        end
      end


      # create game event now, cause we finally have start and end times from the points
      Event.create name: "#{tournament} > #{opponent}", kind: 'Game',
        starts_at: game_start_time-1.second, ends_at: game_end_time+1.second

    end
    puts action_types.keys
  end
end
