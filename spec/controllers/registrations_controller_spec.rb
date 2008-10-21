require File.dirname(__FILE__) + '/../spec_helper'

describe RegistrationsController do
  before do
    login_as @user = User.create_test_user
    @event = @user.events.create! :name => "challenge", :columns => ["name", "phone", "email", "school", "gender"]
  end
  
  describe "GET index" do
    it "should return csv when asked" #do
    #   get :index, :event_id => @event.to_param, :format => 'csv'
    # 
    #   assigns(:registrations).map(&:name).sort.should == %w(karissa toph)
    #   response.content_type.should == "text/csv"
    #   response.body.should include('toph')
    #   response.body.should include('karissa')
    # end
  end
  
  describe "POST create" do
    it "should create a registration" do
      login_as nil
      post :create, :event_id => @event.to_param, 
                    :name => "Jeremy", :phone => "312-953", :email => "jeremy@pivotallabs.com", 
                    :school => 'USC', :gender => "male"
                    
      r = assigns(:registration)
      r.event.should == @event
      r.name.should == "Jeremy"
      r.fields["phone"].should == "312-953"
      r.fields["email"].should == "jeremy@pivotallabs.com"
      r.fields["school"].should == "USC"
      r.fields["gender"].should == "male"

      response.should be_redirect
    end
  end

  describe "GET show" do
    it "should show a registration" do
      reg = create_registration(:name => "reg")
    
      get :show, :event_id => @event.to_param, :id => reg.to_param
    
      assigns(:registration).should == reg
    end
  end
  
  describe "DELETE destroy" do
    it "should destroy a registration" do
      id = create_registration(:name => "foo").id
      request.env["HTTP_REFERER"] = 'http://disneyland.com'
    
      post :destroy, :event_id => @event.to_param, :id => id.to_s
    
      response.should redirect_to('http://disneyland.com')
      Registration.exists?(id).should be_false
    end
  end
  
  describe "PUT update" do
    it "should update a registration" do
      r = create_registration(:name => "foo")
      post :update, :event_id => @event.to_param, :id => r.id, :name => 'charles', :phone => "123"
    
      r.reload
      r.name.should == 'charles'
      r.fields["phone"].should == '123'
      response.should redirect_to(event_registrations_path(@event))
    end
  end
  
  def create_registration(params)
    @event.registrations.create!(:fields => {:phone => "312", :email => 'test@email.com'}.merge(params))
  end
end
