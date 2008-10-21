require File.dirname(__FILE__) + '/../spec_helper'

describe User, "creating a user" do
  before do
    @count = User.count
  end
  
  it "should create a user" do
    user = create_user
    user.should_not be_new_record
    User.count.should == @count + 1
  end

  it "should require password" do
    user = create_user(:password => nil)
    user.errors.on(:password).should include("can't be blank")
    User.count.should == @count
  end

  it "should require password confirmation" do
    user = create_user(:password_confirmation => nil)
    user.errors.on(:password_confirmation).should include("can't be blank")
    User.count.should == @count
  end

  it "should require email" do
    user = create_user(:email => nil)
    user.errors.on(:email).should include("can't be blank")
    User.count.should == @count
  end

  def create_user(options = {})
    User.create({ :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
  end
end

describe User, "with valid user" do
  before do
    @user = User.create! :email => 'quire@example.com', 
                         :password => 'quire', 
                         :password_confirmation => 'quire'
  end

  it "should reset password" do
    @user.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    User.authenticate('quire@example.com', 'new password').should == @user
  end

  it "should not rehash password" do
    @user.update_attributes(:email => 'quentin2@example.com')
    User.authenticate('quentin2@example.com', 'quire').should == @user
  end

  it "should authenticate user" do
    User.authenticate('quire@example.com', 'quire').should == @user
  end

  it "should set remember_token" do
    @user.remember_token.should be_nil

    @user.reload.remember_me
    @user.reload.remember_token.should_not be_nil
    @user.reload.remember_token_expires_at.should_not be_nil
  end
  
  it "should unset remember token" do
    @user.remember_me
    @user.reload.remember_token.should_not be_nil
    
    @user.reload.forget_me
    @user.reload.remember_token.should be_nil
  end
end
