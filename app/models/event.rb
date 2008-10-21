class Event < ActiveRecord::Base
  has_many :registrations
  belongs_to :user

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
    @columns ||= YAML.load(columns_as_yaml || "--- []\n")
  end
  
  def columns=(value)
    self.columns_as_yaml = (@columns = value).to_yaml
  end
  
  def columns_as_yaml=(value)
    self[:columns_as_yaml] = value
    @columns = nil
  end
  
  def valid_column?(column)
    columns.include?(column)
  end
end
