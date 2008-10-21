require File.dirname(__FILE__) + '/../spec_helper'

describe Event do
  describe "to_param" do
    it "should have a sensible to_param" do
      Event.new(:name => "Foo Bar").to_param.should == "foo_bar"
      Event.new(:name => "Foo Bar 2").to_param.should == "foo_bar_2"
      Event.new(:name => "  George  ").to_param.should == "george"
      Event.new(:name => "&--Bob?").to_param.should == "bob"
    end
  
    it "should find_by_url_name" do
      foo_bar = Event.create!(:name => "Foo Bar")
      Event.find_by_url_name("foo_bar").should == foo_bar
    end
  end
  
  describe "columns" do
    it "should default to empty columns" do
      Event.new.columns.should == []
    end
    
    it "should have columns" do
      event = Event.create!(:columns => ["name", "apple", "phone"])
      event.columns.should == ["name", "apple", "phone"]

      event = Event.find(event.id)
      event.columns.should == ["name", "apple", "phone"]
    end
    
    it "should should know valid columns" do
      event = Event.new(:columns => ["apple", "potato"])
      event.should be_valid_column("apple")
      event.should_not be_valid_column("bravo")
      event.should be_valid_column("potato")
    end
  end
end
