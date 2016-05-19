class VideosController < ApplicationController
  def index
    @videos = Video.all.limit(20)
  end

  def show
    @video = Video.find_by_google_id params[:google_id]
  end
end
