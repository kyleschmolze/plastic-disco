
class GoogleImporter
  def initialize(user)
    @user = user
  end

  def import
    #GET https://www.googleapis.com/drive/v2/files?key={YOUR_API_KEY}
    #response = HTTParty.get('http://api.stackexchange.com/2.2/questions?site=stackoverflow')
    #puts response.body, response.code, response.message, response.headers.inspect
    response = HTTParty.get "https://www.googleapis.com/drive/v2/files?key=#{ENV['OMNIAUTH_PROVIDER_KEY']}"
    binding.pry
  end
end
