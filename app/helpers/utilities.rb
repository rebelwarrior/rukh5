# Helper used in various places
module Utilities
  def remove_hyphens(term)
    term.to_s.each_char.select { |chr| chr.match(/[0-9]/) }.join('')
  end
  # def remove_hyphens_from_numbers(term)
  #   term.to_s.each_char.select { |num| num.match(/[0-9]/) }.join('')
  # end
end
