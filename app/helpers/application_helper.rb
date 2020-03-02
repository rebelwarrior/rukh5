# Empty Module
module ApplicationHelper
  # def sortable(column, title = nil)
  #   title ||= column.titleize
  #   css_class = column == sort_column ? "current #{sort_direction}" : nil
  #   direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
  #   link_to (("#{title} #{content_tag(:i, '', :class => "fa fa-chevron-#{direction == 'asc' ? 'up': 'down'}", :style => "font-size: 6px;") if css_class.present?}").html_safe), params.merge(:sort => column, :direction => direction, :page => nil), {:class => css_class}
  # end
  # def sortable(column, title = nil, sort_column = "id", sort_direction = "asc")
  #   title ||= column.titleize
  #   if column != sort_column
  #     css_class = nil
  #   elsif sort_direction == "asc"
  #     # css_class = "glyphicon glyphicon-triangle-top"
  #     css_class = "fa fa-chevron-up"
  #   else
  #     # css_class = "glyphicon glyphicon-triangle-bottom"
  #     css_class = "fa fa-chevron-down"
  #   end
  #   direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
  #
  #   link_to "#{title} <span class='#{css_class}'></span>".html_safe, {:sort => column, :direction => direction}
  # end
  # def sortable(title, column, type = nil)
  #   if (type == 'events')
  #     path = events_path
  #   end
  #
  #   path = path + "?sort=#{column}"
  #
  #   color = sort_column == column ? 'secondary' : ''
  #
  #   link_to path, class: "button small #{color}", id: column do
  #     "#{title}".html_safe
  #   end
  # end
  def sort_arrows(direction)
    if direction == "desc"
      'fa fa-chevron-down'
    elsif direction == "asc"
      'fa fa-chevron-up'
    else 
      ''
    end
  end 
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
    
end
