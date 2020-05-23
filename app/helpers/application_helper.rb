module ApplicationHelper
  # Changes direction for Sort Arrows
  def sort_arrows(direction)
    {"desc" => 'fa fa-chevron-down', "asc" => 'fa fa-chevron-up'}
      .fetch(direction, '')
  end

  # Toggles direction based on current direction
  def toggle_direction(direction)
    {"desc" => "asc", "asc" => "desc"}.fetch(direction, '')
  end

  # Changes language parameter to new language
  def toggle_lang_param(lang)
    params.permit!.merge(locale: lang) if I18n.locale_available? lang
  end
end
