module ApplicationHelper
  def sortable(column, title)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == 'asc') ? "desc" : "asc"
    link_to title, sort: column, direction: direction
  end
  def show_date(date)
    date.strftime("%Y/%m/%d (%a.)") if date.present?
  end
  def show_time(time)
    time.strftime("%H:%M") if time.present? 
  end
  def show_datetime(datetime)
    datetime.strftime("%Y/%m/%d %H:%M") if datetime.present?
  end
  def show_currency(number)
    number_to_currency(number, format: "%u%n", unit: "￥", precision: 0, separator: ",") if number.present?
  end

  def show_role(member, event)
    @record = member.relationships.find_by_event_id(event.id)
    @prenseter_flg = @record.presenter_flg
    @guest_flg = @record.guest_flg
    @gtic_flg = member.gtic_flg
    @student_flg = member.category_id == 10 ? true : false
    if @gtic_flg
      return "GTIC"
    elsif @presenter_flg
      return "プレゼンター"
    elsif @guest_flg
      return "ゲスト"
    elsif @student_flg
      return "学生"
    else
      return "参加者"
    end
  end



end
