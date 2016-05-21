class VideosController < ApplicationController
  def index
    @videos = Video.order('starts_at ASC').paginate(page: params[:page], per_page: 100)
  end

  def show
    @video = Video.find_by_google_id params[:google_id]
  end

  def import
    if user_signed_in? and !current_user.token_expired?
      current_user.import_videos
      redirect_to root_path, notice: "Videos imported!"
    else
      redirect_to root_path, notice: "Please login in again for a fresh access token."
    end
  end
end
