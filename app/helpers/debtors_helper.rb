# Methods to help Debtors

module DebtorsHelper
  include Pagy::Frontend
  # Includes an example of refactoring for clarity and understanding
  # Note the refactoring shows the shortest method is not the clearest.

  def _display_tel_old(string)
    # Left here for documentation
    # first attempt refactored below.
    nums = string.split('')
    last_four = nums.pop(4).join('')
    next_three = nums.pop(3).join('')
    area_code = nums.pop(3).join('')
    "(#{area_code})#{next_three}-#{last_four}"
  end

  # rubocop:disable Naming/UncommunicativeMethodParamName
  def _display_tel_new(s)
    # Indexes the string back to front
    # to display as a telephone number format;
    # Refactored below for understandability.
    "(#{s[-10..-8]})#{s[-7..-5]}-#{s[-4..-1]}"
  end
  # rubocop:enable Naming/UncommunicativeMethodParamName

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

module DebtorsBackendHelper
  include Utilities

  def self.remove_hyphens_from_numbers(term)
    Utilities.remove_hyphens(term)
    # term.to_s.each_char.select { |x| x.match(/[0-9]/) }.join('')
  end

  def self.encrypt(token, digester = Digest::SHA1, salt = Rails.application.secrets.salt)
    salted = salt(remove_hyphens_from_numbers(token), salt)
    digester.hexdigest(salted.to_s)
  end

  def self.salt(token, salt = Rails.application.secrets.salt)
    # salt stored in secrets.yml
    fail(ArgumentError, 'Nil propagation, token not set', caller) if token.nil?
    fail(ArgumentError, 'Rails Salt (config/secret.yml) not set', caller) if salt.nil?

    token.to_i + salt
  end

  def self.guard_length(token, length = 9)
    # Should be renamed
    size = token.to_s.size
    fail "Not proper length: #{size}. Expected #{length}." unless size == length
  end
end
