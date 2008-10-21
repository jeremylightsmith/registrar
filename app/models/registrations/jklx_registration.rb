# class JklxRegistration < Registration
#   validates_inclusion_of :gender, :in => [nil, "male", "female"]
#   validates_inclusion_of :shirt_size, :in => %w(- S M L)
#   
#   fields :name, :paid, :phone, :email, :notes, :gender, :address, :local, :needs_housing, :can_host, :can_volunteer, :shirt_size
#   
#   booleans :local, :can_host, :can_volunteer, :needs_housing
#   
#   def controller
#     "jeremy_and_karissa_exchange"
#   end
#   
#   def amount
#     value = 50
#     value += 10 if Date.today > Date.parse("May 16, 2008")
#     value += 15 unless shirt_size.blank? || shirt_size == "-"
# 
#     "#{value}.00"
#   end
# end