module ApplicationHelper
  def sortable(column, title)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == 'asc') ? "desc" : "asc"
    link_to title, sort: column, direction: direction
  end
  def show_date(date)
    date.strftime("%Y/%m/%d (%a.)") if date.class == (Date || DateTime)
  end
  def show_time(time)
    time.strftime("%H:%M") if time.class == (Time || DateTime)
  end
  def show_currency(number)
    number_to_currency(number, format: "%u%n", unit: "￥", precision: 0, separator: ",") if number.class == (Integer || Float)
  end

end
