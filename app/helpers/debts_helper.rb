module DebtsHelper
  # TODO: duplicated in Debtor Model
  # Moved to Utilities remove
  def remove_hyphens(term)
    term.to_s.each_char.select { |x| x.match(/[0-9]/) }.join('')
  end
end
