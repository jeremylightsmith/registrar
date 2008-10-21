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
    value = @registration.send(name)
    value = "X" if value == true
    value = "" if value == false

    markaby do
      tr do
        th name.to_s
        td do
          if block_given?
            yield
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
end
