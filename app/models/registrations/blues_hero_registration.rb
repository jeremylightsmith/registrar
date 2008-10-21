# class BluesHeroRegistration < Registration
#   LIMIT = 30 # each day
#   validates_inclusion_of :role, :in => %w(lead follow), :message => 'choose one'
#   validates_inclusion_of :package, :in => %w(saturday sunday weekend), :message => 'choose one'
# 
#   fields :name, :paid, :phone, :email, :notes, :role, :city, :carpool, :carpool_spaces, :package
#   
#   def controller
#     "blues_hero"
#   end
#   
#   def amount
#     case package
#     when "saturday": "65.00"
#     when "sunday": "65.00"
#     when "weekend": "125.00"
#     end
#   end
#   
#   def self.how_many_left_on(package)
#     LIMIT - BluesHeroRegistration.find(:all).select {|r| 
#       !r.paid.blank? && [package.to_s, "weekend"].include?(r.package)
#     }.size
#   end
# end