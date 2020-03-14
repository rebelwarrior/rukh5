module ApplicationHelper
  # Changes direction for Sort Arrows
  def sort_arrows(direction)
    if direction == "desc"
      'fa fa-chevron-down'
    elsif direction == "asc"
      'fa fa-chevron-up'
    else
      ''
    end
  end

  # Toggles direction based on current direction
  def toggle_direction(direction)
    case direction
    when "desc"
      "asc"
    when "asc"
      "desc"
    else
      ''
    end
  end

  # Changes language parameter to new language
  def toggle_lang_param(lang)
    params.permit!.merge(locale: lang) if %i[en es].include? lang
  end
end
