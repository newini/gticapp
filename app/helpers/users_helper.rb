module UsersHelper
  def show_language(int)
    case int
    when 0
      "JP"
    when 1
      "EN"
    end
  end

end
