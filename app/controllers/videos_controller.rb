class VideosController < ApplicationController
  def index
    @videos = Video.includes(:events).order('starts_at ASC').paginate(page: params[:page], per_page: 100)
  end

  def show
    @video = Video.find params[:id]
  end

  def import
    if user_signed_in? and !current_user.token_expired?
      current_user.import_videos
      redirect_to root_path, notice: "Videos imported!"
    else
      redirect_to root_path, notice: "Please login in again for a fresh access token."
    end
  end

  def tag
    @video = Video.find params[:id]
    @event = Event.find params[:event_id]
    seconds_into_clip = params[:seconds_into_clip]
    minutes_into_clip = params[:minutes_into_clip]
    if @video.blank? or @event.blank? or seconds_into_clip.blank?
      render json: { success: 0 }, status: 422
    else
      @video.starts_at = @event.starts_at - minutes_into_clip.to_i.minutes - seconds_into_clip.to_i.seconds
      @video.save
      @video.tag_events
      render json: { success: 1 }, status: 201
    end
  end
end
