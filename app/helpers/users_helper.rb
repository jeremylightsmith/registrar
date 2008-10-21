module UsersHelper
  def user_fields(f, user)
    markaby do
      dl do
        dt "Name:"
        dd do
          text f.text_field(:name)
        end

        dt "Email:"
        dd do
          text f.text_field(:email)
          p.hint "e.g. myname@example.com"
        end

        dt "Choose a password:"
        dd {f.password_field :password}

        dt "Re-enter password:"
        dd {f.password_field :password_confirmation}
        
        if logged_in? && current_user.admin?
          dt "Admin?:"
          dd do
            select_tag "user[admin]", options_for_select([['No', 0], ['Yes', 1]], user.admin? ? 1 : 0)
          end
        end
      end
    end
  end
end
