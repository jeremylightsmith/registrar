class Event < ActiveRecord::Base
  has_many :registrations

  def name=(value)
    self[:name] = value
    self[:url_name] = value.gsub(/[^a-zA-Z0-9]/, ' ').strip.gsub(" ", "_").downcase
  end
  
  def to_param
    url_name
  end
  
  def csv_columns
    columns
  end
  
  def columns
    @columns ||= YAML.load(self[:columns] || "--- []\n")
  end
  
  def columns=(value)
    self[:columns] = (@columns = value).to_yaml
  end
  
  def valid_column?(column)
    columns.include?(column)
  end
end
