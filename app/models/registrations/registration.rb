class Registration < ActiveRecord::Base
  belongs_to :event
  before_save :store_fields

  def city_state_zip
    join(' ', join(', ', city, state), zip)
  end
  
  def address
    join("\n", street, city_state_zip, country)
  end
  
  def name
    fields["name"]
  end
  
  def name=(value)
    fields["name"] = value
  end
  
  def amount
    fields["amount"]
  end
  
  def amount=(value)
    fields["amount"] = value
  end
  
  def fields=(value)
    fields.merge! value
  end
  
  def fields
    @fields ||= YAML.load(self[:yaml] || "--- {}\n")
  end
  
  def reload
    @fields = nil
    super
  end
  
  private

  def store_fields
    fields.stringify_keys!
    fields.each do |key, value|
      raise "unknown column #{key.inspect}" unless !event || event.valid_column?(key)
    end
    self[:yaml] = fields.to_yaml
  end
  
  def join(with, *values)
    result = values.compact.join(with)
    result.blank? ? nil : result
  end
end
