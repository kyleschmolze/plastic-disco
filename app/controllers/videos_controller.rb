class VideosController < ApplicationController
  def index
    @videos = Video.includes(:events).order('starts_at ASC').paginate(page: params[:page], per_page: 100)
  end

  def show
    @video = Video.find params[:id]
    respond_to do |format|
      format.html
      format.json
    end
  end

  def update
    @video = Video.find params[:id]
    if @video.update(video_params)
      respond_to do |format|
        format.html { redirect_to video_path(@video) }
        format.json { render json: { success: 1 }, status: 202 }
      end
    else
      respond_to do |format|
        format.html { render :show }
        format.json { render json: { success: 0 }, status: 400 }
      end
    end
  end

  def align_to_event
    @video = Video.find params[:id]
    @event = Event.find params[:event_id]
    seconds_into_clip = params[:seconds_into_clip]
    minutes_into_clip = params[:minutes_into_clip]||0
    if @event.blank? or seconds_into_clip.blank?
      render json: { success: 0 }, status: 422
    else
      @video.starts_at = @event.starts_at - minutes_into_clip.to_i.minutes - seconds_into_clip.to_i.seconds
      @video.ends_at = @video.starts_at + @video.duration.seconds
      @video.aligned = true
      @video.save
      @video.tag_events
      render json: { success: 1 }, status: 201
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

private

  def video_params
    params.fetch(:video, {}).permit :starts_at, :ends_at, :aligned, :hidden
  end
end
