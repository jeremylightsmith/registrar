require File.dirname(__FILE__) + '/../../spec_helper'

describe Registration do
  describe "simple columns" do
    before do
      @event = Event.create! :name => "Stuff", :columns => ["name", "email", "phone", "gender"]
      @registration = @event.registrations.build(:name => "jay", :fields => {:email => "j@foo", :phone => '312'})
    end

    it "should be valid" do
      @registration.should be_valid
    end
  
    it "should save" do
      @registration.save!
      @registration = Registration.find(@registration.id)
      @registration.name.should == "jay"
      @registration.fields["email"].should == "j@foo"
      @registration.fields["phone"].should == "312"
    end
  
    it "should not let a user save a field that it doesn't know about" do
      proc {@registration.school = "USC"}.should raise_error
    end
  end
  
  describe "more columns" do
    before do
      @event = Event.create! :name => "Stuff", :columns => ["name", "phone", "email", "bob", "uncle"]
      @registration = @event.registrations.build(:name => "jay", :fields => {:email => "j@foo", :phone => '312'})
    end
    
    it "should have fields" do
      foo = @event.registrations.create!(:name => 'bob', :fields => {:phone => '312-953-1193', :email => 'bob@foo', :bob => 'likes you', :uncle => 'crap'})
      foo = Registration.find(foo.id)
      foo.name.should == 'bob'
      foo.fields["email"].should == 'bob@foo'
      foo.fields["bob"].should == 'likes you'
    end    
  end
end
