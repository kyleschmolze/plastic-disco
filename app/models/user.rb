class User < ActiveRecord::Base

  has_many :videos
  has_many :events

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
end
