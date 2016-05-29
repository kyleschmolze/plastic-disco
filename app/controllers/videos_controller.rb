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

  def align
    @video = Video.find params[:id]
    if params[:event_id].blank?
      # we're just marking it aligned
      @video.update aligned: true
      render json: { success: 0 }, status: 422
    else
      # we were given an event, so we're aligning to it
      @event = Event.find params[:event_id]
      seconds_into_clip = params[:seconds_into_clip]
      minutes_into_clip = params[:minutes_into_clip]||0
      if @event.blank? or seconds_into_clip.blank?
        render json: { success: 0 }, status: 422
      else
        @video.starts_at = @event.starts_at - minutes_into_clip.to_i.minutes - seconds_into_clip.to_i.seconds
        @video.ends_at = @video.starts_at + (@video.duration/1000).seconds
        @video.aligned = true
        @video.save
        @video.tag_events
        render json: { success: 1 }, status: 201
      end
    end
  end

  def unalign
    @video = Video.find params[:id]
    @video.starts_at = @video.original_starts_at
    @video.ends_at = @video.original_ends_at
    @video.aligned = false
    @video.tag_events
    @video.save
    redirect_to video_path(@video)
  end
end
