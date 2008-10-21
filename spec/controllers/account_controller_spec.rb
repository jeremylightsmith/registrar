require File.dirname(__FILE__) + '/../spec_helper'

describe AccountController, "with a user" do
  include AuthenticatedTestHelper
  
  before do
    @user = User.create! :email => 'quentin@example.com', 
                         :password => 'test', 
                         :password_confirmation => 'test'
    @count = User.count
  end
  
  it "should login and redirect" do
    post :login, :email => 'quentin@example.com', :password => 'test'
    
    session[:user].should_not be_nil
    response.should be_redirect
  end

  it "should login and redirect to referring page" do
    request.env['HTTP_REFERER'] = "http://burnblue.org/"
    get :login

    request.env['HTTP_REFERER'] = "http://burnblue.org/account/login"
    post :login, :email => 'quentin@example.com', :password => 'bad password'
    post :login, :email => 'quentin@example.com', :password => 'test'
    
    response.should redirect_to("http://burnblue.org/")
  end

  it "should fail login and not redirect" do
    post :login, :email => 'quentin@example.com', :password => 'bad password'
    session[:user].should == nil
    response.should be_success
  end

  it "should allow signup" do
    create_user
    response.should be_redirect
    
    User.count.should == @count + 1
  end

  it "should require email on signup" do
    create_user(:email => nil)
    
    assigns(:user).errors.on(:email).should include("can't be blank")
    response.should be_success
    User.count.should == @count
  end

  it "should require password on signup" do
    create_user(:password => nil)
    assigns(:user).errors.on(:password).should include("can't be blank")
    response.should be_success
    User.count.should == @count
  end

  it "should require a possword confirmation on signup" do
    create_user(:password_confirmation => nil)
    assigns(:user).errors.on(:password_confirmation).should_not be_nil
    response.should be_success

    User.count.should == @count
  end

  it "should logout" do
    login_as @user
    get :logout
    session[:user].should be_nil
    response.should be_redirect
  end
  
  it "should remember me" do
    post :login, :email => 'quentin@example.com', :password => 'test', :remember_me => "1"
    cookies["auth_token"].should_not be_nil
  end

  it "should not remember me" do
    post :login, :login => 'quentin', :password => 'test', :remember_me => "0"
    cookies["auth_token"].should be_nil
  end

  it "should delete token on logout" do
    login_as @user
    get :logout
    cookies["auth_token"].should == []
  end
  
  it "should login with cookie" do
    @user.remember_me
    request.cookies["auth_token"] = cookie_for(@user)
    get :index
    controller.should be_logged_in
  end

  it "should fail expired cookie login" do
    @user.remember_me
    @user.update_attribute :remember_token_expires_at, 5.minutes.ago
    request.cookies["auth_token"] = cookie_for(@user)
    get :index
    controller.should_not be_logged_in
  end

  it "should fail cookie login" do
    @user.remember_me
    request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :index
    controller.should_not be_logged_in
  end
  
  it "should return to previous page after logout" do
    login_as @user
    
    request.env['HTTP_REFERER'] = "http://burnblue.org/"
    get :logout
    
    response.should redirect_to("http://burnblue.org/")
  end

  private

  def create_user(options = {})
    post :signup, :user => { :email => 'quire@example.com', 
                             :password => 'quire', 
                             :password_confirmation => 'quire' }.merge(options)
  end
  
  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
  
  def cookie_for(user)
    auth_token user.remember_token
  end
end