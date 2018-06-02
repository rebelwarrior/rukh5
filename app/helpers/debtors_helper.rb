module DebtorsHelper
  include Pagy::Frontend
  
  def display_tel_old(string)
    # Left her for documentation
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

  def display_tel(s)
    # Display as a telephone number format.
    last_four = s[-4..-1]
    next_three = s[-7..-5]
    area_code = s[-10..-8]
    "(#{area_code})#{next_three}-#{last_four}"
  end

  def display_ext(s)
    "ext: #{s} "
  end
end
