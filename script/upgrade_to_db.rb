#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/environment'

def into_contacts(names)
  names.find_all{|name| name != "dont_know"}.map do |name|
    name = name.titleize
    contact = Contact.find_by_name(name)
    contact = Contact.create!(:name => name) unless contact
    contact
  end
end

def update_contact(name, params)
  Contact.find_by_name(name).update_attributes!(params)
end  

Contact.delete_all
StaffMember.delete_all
Event.delete_all

Dir[RAILS_ROOT + "/db/events/2007/*"].each do |file|
  month, day, name = File.basename(file).sub(".yml", "").split("-")
  puts "2007/#{month}/#{day}"
  date = Date.parse("2007/#{month}/#{day}")
  
  yml = YAML::load(File.read(file))
  if yml.has_key? 'redirect_to'
    LinkEvent.create!(:name => name, :date => date, :external_url => yml["redirect_to"])
  else
    BurnBlueEvent.create!(:name => name, :date => date,
                           :hosts => into_contacts(yml["hosts"]),
                           :teachers => into_contacts(yml["teachers"]),
                           :djs => into_contacts(yml["djs"]))
  end
end

update_contact("Jeremy Stell Smith", :name => "Jeremy Stell-Smith")
update_contact("Chris Chapman", :nick_name => "Chris C")
update_contact("Chris Gerdes", :nick_name => "Chris G")
update_contact("Brenda Ck", :name => "Brenda CK", :nick_name => "Brenda CK")
