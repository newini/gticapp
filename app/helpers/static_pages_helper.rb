module StaticPagesHelper
  def get_member_name(member_id)
    member = Member.find_by_id(member_id)
    return member.last_name + " " + member.first_name
  end

  def get_member_english_name(member_id)
    member = Member.find_by_id(member_id)
    return member.first_name_alphabet + " " + member.last_name_alphabet
  end

  def select_locale
    case params[:locale]
    when nil, 'ja'
      locale_now = ['Japanese', 'ja']
      locale_array = [ ['English', 'en'] ]
    when 'en'
      locale_now = ['English', 'en']
      locale_array = [ ['Japanese', 'ja'] ]
    end

    content_tag(:li, class: "nav-item dropdown") {
      concat content_tag(:a, href: '#', id: 'dropdowmLocale',class: "nav-link dropdown-toggle py-0", data: {toggle: "dropdown"}, 'aria-haspopup': "true", 'aria-expanded': "false") {
        content_tag(:b, locale_now[0], class: "caret")
      }
      concat content_tag(:div, class: "dropdown-menu", id: 'dropdowmLocale') {
        locale_array.each do |locale|
          concat link_to(locale[0], {locale: locale[1]}, class: 'dropdown-item')
        end
      }
    }
  end
end
