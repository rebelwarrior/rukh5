# Helper used in various places
module Utilities
  def remove_hyphens(term)
    term.to_s.each_char.select { |x| x.match(/[0-9]/) }.join('')
  end
end
