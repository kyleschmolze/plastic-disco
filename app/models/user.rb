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
end
