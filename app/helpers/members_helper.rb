module MembersHelper

  def show_gender(gender)
    if gender == 1
      return "Male"
    elsif gender == 2
      return "Female"
    end
  end

  def show_age(age)
    if age == 1
      return "~20s"
    elsif age == 2
      return "30s"
    elsif age == 3
      return "40s"
    elsif age == 4
      return "50s"
    elsif age == 5
      return "60s~"
    end
  end

end
