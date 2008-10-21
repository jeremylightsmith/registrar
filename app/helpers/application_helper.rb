# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include ActionView::Helpers::AssetTagHelper
  
  def page_title(name)
    markaby do
      content_for(:title) { name.to_s }
    end    
  end
  
  def string_path(string)
    string
  end
  
  def state_select(form, name)
    form.select(name, [''] + %w(AL AK AZ AR CA CO CT DE DC FL GA HI IA ID IL IN KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY).sort)
  end
end
