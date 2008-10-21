# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie
  
  protected
  
  def self.style(name)
    before_filter do |controller|
      controller.assigns["stylesheet"] = name
    end
  end
  
  def adjust_format_for_language
    request.format = :spanish if session[:language] == "spanish"
    puts "request is now #{request.format} & language is #{session[:language]}"
  end
    
  def admin_required
    raise "You do not have permission to see this page" unless current_user.admin?
  end
  
  def remember(name, value = nil)
    if value
      cookies[name.to_s] = {:value => value, :expires => 20.years.from_now}
    else
      return request.cookies[name.to_s].first unless request.cookies[name.to_s].nil?
    end
  end    
end
