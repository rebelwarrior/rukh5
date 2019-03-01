# Methods to help Debtors 
# Includes an example of refactoring for clarity and understanding
# Note the refactoring shows the shortest method is not the clearest. 
module DebtorsHelper
  include Pagy::Frontend
  
  def display_tel_old(string)
    # Left here for documentation
    # first attempt refactored below.
    nums = string.split('')
    last_four = nums.pop(4).join('')
    next_three = nums.pop(3).join('')
    area_code = nums.pop(3).join('')
    "(#{area_code})#{next_three}-#{last_four}"
  end

  def display_tel_next(s)
    # Indexes the string back to front
    # to display as a telephone number format;
    # Refactored below for understandability.
    "(#{s[-10..-8]})#{s[-7..-5]}-#{s[-4..-1]}"
  end

  def display_tel(string)
    # Display as a telephone number format.
    last_four  = string[-4..-1]
    next_three = string[-7..-5]
    area_code  = string[-10..-8]
    "(#{area_code})#{next_three}-#{last_four}"
  end

  def display_ext(string)
    "ext: #{string} "
  end
end
