require File.dirname(__FILE__) + '/../spec_helper'

describe EventsController do
  before :each do
    @user = User.create_test_user
    @blues_hero = @user.events.create!(:name => "blues hero")
    login_as @user
  end
  
  describe "GET index" do
    it "should show all events for user" do
      jazz_jubilee = @user.events.create!(:name => "jazz jubilee")
      
      get :index
      
      response.should be_success
      assigns(:events).should == [@blues_hero, jazz_jubilee]
    end
  end
  
  describe "GET show" do
    it "should show an event" do
      get :show, :id => @blues_hero.to_param
     
      response.should be_success
      assigns(:event).should == @blues_hero
    end
  end
  
  describe "PUT update" do
    it "should update an event" do
      put :update, :id => @blues_hero.to_param, :event => {:name => "challenge", :columns_as_yaml => "---\n- a\n- b\n- c"}
      
      @blues_hero.reload
      @blues_hero.name.should == "challenge"
      @blues_hero.columns.should == %w(a b c)

      response.should redirect_to(events_path)
    end
  end
  
  describe "POST create" do
    it "should create an event" do
      post :create, :event => {:name => 'blues hero'}
      
      @user.reload.events.size.should == 2
      event = @user.events.last
      event.name.should == 'blues hero'
      response.should redirect_to(events_path)
    end
  end
end
