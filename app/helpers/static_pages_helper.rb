module StaticPagesHelper
  def select_locale
    case params[:locale]
    when nil, 'ja'
      locale_now = ['日本語', 'ja']
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
