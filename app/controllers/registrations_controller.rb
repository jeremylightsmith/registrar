require 'faster_csv'

class RegistrationsController < ApplicationController
  before_filter :login_required, :except => ['create', 'mark_paid']
  before_filter :load_event
  layout "application"
  
  def index
    @registrations = @event.registrations :order => 'updated_at desc'
    if params[:sort]
      @registrations = sort(@registrations, params[:sort].to_sym, params[:direction].to_sym)
    end

    respond_to do |format|
      format.html
      format.csv { index_as_csv }
    end
  end

  def show
    @registration = @event.registrations.find(params[:id])
  end
  
  def create
    @registration = @event.registrations.create!(:fields => white_list(params))
    @paypal_url = RAILS_ENV == 'production' ? 
                    "https://www.paypal.com/cgi-bin/webscr" : 
                    "https://www.sandbox.paypal.com/cgi-bin/webscr"
    
    render :action => "paypal"
  end
  
  def edit
    show
  end
  
  def update
    show
    @registration.update_attributes!(:fields => white_list(params))
    redirect_to event_registrations_path(@event)
  end
  
  def destroy
    @event.registrations.find(params[:id]).destroy
    redirect_to :back
  end
  
  def mark_paid
    @registration = @event.registrations.find(params[:id])
    @registration.paid = "yup"
    @registration.save!

    flash["notice"] =  "Thanks for paying!"
    redirect_to :controller => @registration.controller, :action => "payment_received", :id => @registration.id
  end
  
  private
  
  def white_list(params)
    params = params.dup
    %w(controller action event_id id).each {|key| params.delete(key)}
    params
  end
  
  def index_as_csv
    csv_string = FasterCSV.generate do |csv|
      csv << @event.csv_columns.map{|c| c.to_s.titleize}
      
      @registrations.each do |r|
        csv << @event.csv_columns.map do |c| 
          val = r.send(c)
          case val
          when true: 'x'
          when false: '-'
          when nil, '': '-'
          else
            val.is_a?(String) ? val.gsub("\r", " ").gsub("\n", "  ") : val
          end
        end
      end
    end

    # send it to the browsah
    send_data csv_string,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=users.csv"
  end
  
  def sort(list, by, order)
    list = if [:created_at, :updated_at].include?(by)
      list.sort{|a,b| a.send(by) <=> b.send(by) }
    else
      list.sort {|a,b| a.send(by).to_s.downcase <=> b.send(by).to_s.downcase }
    end
    order == :down ? list : list.reverse
  end
  
  def load_event
    @event = Event.find_by_url_name(params[:event_id])
  end
end
