require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController, "without logging in" do
  it "should require admin login" do
    bob = User.create_test_user("bob")
    login_as bob
    proc { get :index }.should raise_error
  end

  it "should require login" do
    get :index
    
    response.should redirect_to("/account/login")
  end
end

describe UsersController do
  before do
    @admin = User.create_test_admin
    @bob = User.create_test_user("bob")
    @jack = User.create_test_user("jack")

    login_as @admin
  end

  it "should show users" do
    get :index
    
    response.should be_success
    assigns(:users).should include(@admin)
    assigns(:users).should include(@bob)
    assigns(:users).should include(@jack)
  end
  
  it "should create a user" do
    get :create, :user => {:name => 'george', :email => 'george@jungle.com', :password => 'jungle', :password_confirmation => 'jungle'}
    
    assigns(:user).name.should == 'george'
    assigns(:user).should be_authenticated("jungle")
  end
  
  it "should update user, and not change pass" do
    get :update, :id => @bob.id, :user => {:name => 'george', :password => '', :password_confirmation => ''}
    
    @bob.reload.name.should == 'george'
    @bob.should be_authenticated("pass")
  end
  
  it "should update user, and change pass" do
    get :update, :id => @bob.id, :user => {:name => 'george', :password => 'jungle', :password_confirmation => 'jungle'}
    
    @bob.reload.name.should == 'george'
    @bob.should be_authenticated("jungle")
  end
  
  it "should destroy a user" do
    delete :destroy, :id => @bob.id
    
    response.should redirect_to("/users")
    User.exists?(@bob.id).should be_false
  end
end
