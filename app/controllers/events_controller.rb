class EventsController < ApplicationController
  def index
    dui_start = Date.parse 'Fri, 01 Apr 2016'
    dui_end = Date.parse 'Mon, 04 Apr 2016'
    @events = Event.includes(:videos).order('starts_at ASC').paginate(page: params[:page], per_page: 100)
  end

  def search
    if params[:require_video]
      @events = Event.with_query(params[:query]).joins(:videos).group('events.id')
                     .order('starts_at ASC').limit(100).offset(params[:offset] || 0)
    else
      @events = Event.with_query(params[:query])
                     .includes(:videos).order('starts_at ASC').limit(100).offset(params[:offset] || 0)
    end
  end

  def show
    @event = Event.find params[:id]
    @videos = @event.videos
  end
end
