# require File.dirname(__FILE__) + '/../../spec_helper'
# 
# describe BluesHeroRegistration do
#   before do
#     @reg = BluesHeroRegistration.new :name => 'bob', :phone => '123', :email => 'bob@you', :role => 'lead', :package => 'saturday'
#   end
#   
#   it "should save" do
#     @reg.save!
#   end
#   
#   it "should complain if name is missing" do
#     @reg.name = nil
#     @reg.should have(1).error_on(:name)
#   end
#   
#   it "should complain if role is invalid" do
#     @reg.role = nil
#     @reg.should have(1).errors_on(:role)
#     @reg.role = 'male'
#     @reg.should have(1).errors_on(:role)
#     @reg.role = 'lead'
#     @reg.should have(0).errors_on(:role)
#   end
#   
#   it "should complain if package is invalid" do
#     @reg.package = nil
#     @reg.should have(1).errors_on(:package)
#     @reg.package = 'male'
#     @reg.should have(1).errors_on(:package)
#     @reg.package = 'sunday'
#     @reg.should have(0).errors_on(:package)
#   end
#   
#   it "should know how many people sign up for which days" do
#     create_reg("saturday", "yup")
#     create_reg("saturday", "10")
#     create_reg("saturday", "")
#     create_reg("sunday", "yup")
#     create_reg("weekend", "yup")
#     create_reg("weekend", nil)
#     
#     BluesHeroRegistration.how_many_left_on(:saturday).should == 30 - 3
#     BluesHeroRegistration.how_many_left_on(:sunday).should == 30 - 2
#   end
#   
#   def create_reg(package, paid)
#     BluesHeroRegistration.create!(:role => 'lead', :paid => paid, :package => package, :name => 'bob', :phone => '124', :email => 'bob@bob')
#   end
# end