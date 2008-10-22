module RegistrationsHelper
  def row(value)
    markaby do
      td do
        if value.blank? || value == false
          text "&nbsp;"
        elsif value == true
          text "X"
        else
          text value
        end
      end
    end
  end

  def field(name)
    value = @registration.fields[name]
    value = "X" if value == true
    value = "" if value == false

    markaby do
      tr do
        th name.to_s
        td do
          if block_given?
            yield value
          else
            value
          end
        end
      end
    end
  end
    
  def separator
    markaby do
      tr do
        td :colspan => 2, :style => 'border-bottom: solid 1px black' do
          "&nbsp;"
        end
      end
    end
  end
  
  def column_header(column)
    name = column.to_s
    title = name.titleize
    direction = "down"
    
    if params[:sort] == name
      if params[:direction] == 'down'
        title += image_tag('/images/icons/down.png')
        direction = "up"
      else
        title += image_tag('/images/icons/up.png')
      end
    end

    link_to title, event_registrations_path(@event, :sort => name, :direction => direction)
  end
end
