class AddOauthResponseToUsers < ActiveRecord::Migration
  def change
    add_column :users, :oauth_response, :json
  end
end
