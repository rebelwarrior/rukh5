module ApplicationHelper
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
