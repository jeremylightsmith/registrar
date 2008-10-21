class AccountController < ApplicationController
  layout "application"
  style "/account"
  
  # say something nice, you goof!  something sweet.
  def index
    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
  end

  def login
    session[:return_to] = request.env['HTTP_REFERER'] unless session[:return_to]
    params[:email] ||= remember :email
    return unless request.post?
    
    self.current_user = User.authenticate(params[:email], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => '/account', :action => 'index')
      flash[:notice] = "Logged in successfully"
      remember :email, self.current_user.email
    else
      flash.now[:error] = "Wrong email or password"
      if params[:login_form]
        flash[:error] = flash.now[:error]
        redirect_to params[:login_form]
      end
    end
  end

  def signup
    @user = User.new(params[:user])
    return unless request.post?
    @user.save!
    self.current_user = @user
    redirect_back_or_default(:controller => '/account', :action => 'index')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    if request.env['HTTP_REFERER']
      redirect_to(request.env['HTTP_REFERER'])
    else
      redirect_back_or_default(:controller => '/account', :action => 'index')
    end
  end
end
