class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.string   :email
      t.string   :crypted_password,          :limit => 40
      t.string   :salt,                      :limit => 40
      t.string   :remember_token
      t.datetime :remember_token_expires_at
      t.boolean  :admin,                                   :default => false
      t.string   :name
      
      t.timestamps
    end
    
    User.create! :name => "Jeremy Lightsmith",
                 :email => "jeremy.lightsmith@gmail.com", 
                 :crypted_password => "9ac40e94eaf4da3f16228b39cf8d38579e96deb3",
                 :salt => "6ab8801ecd5d8665d603fb5b21c8a7a39d881bdd",
                 :admin => true
  end

  def self.down
    drop_table :users
  end
end
