class EventsController < ApplicationController
  before_filter :login_required
  
  def index
    @events = current_user.events
  end
  
  def show
    @event = Event.find_by_url_name(params[:id])
  end
  
  def create
    event = current_user.events.create! params[:event]
    redirect_to events_path
  end
  
  def update
    @event = Event.find_by_url_name(params[:id])
    @event.update_attributes!(params[:event])
    
    redirect_to events_path
  end
end
