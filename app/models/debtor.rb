require 'hex_string'

class Debtor < ApplicationRecord
  # TODO: remove calls to Model#encrypt for a more universal method.
  has_many :debts

  ## Hooks
  before_save { self.email = email.downcase if email }
  # before_save { self.uses_personal_ss = ss_hex_digest.blank? ? true : false }
  before_save { self.ss_hex_digest = ss_hex_digest.blank? ? '' : Debtor.encrypt(ss_hex_digest) }
  before_save { self.tel = tel ? Debtor.remove_hyphens(tel) : '' }

  ## REGEX
  VALID_EMAIL_REGEX = /\A(\z|[\w+\-.]+@[a-z\d\-.]+\.[a-z]+)\z/i.freeze
  VALID_TEL_REGEX = /\A(\z|([0-9]{3}-?[0-9]{3}-?[0-9]{4}))\z/.freeze
  VALID_EIN_REGEX = /\A(\z|([0-9]{2})-?([0-9]{7}))\z/.freeze
  VALID_SS_REGEX = /\A(\z|([0-9]{3}-?[0-9]{2}-?[0-9]{4}))\z/.freeze

  ## Validations
  validates :name, presence: true
  validates :email, format: { with: VALID_EMAIL_REGEX,
                              message: I18n.t('validation_error.invalid_email') }
  validates :tel, format: { with: VALID_TEL_REGEX,
                            message: I18n.t('validation_error.must_be_valid_tel') }
  validates :employer_id_number, absence: true,
                                 unless: proc { |debtor_ex| debtor_ex.ss_hex_digest.blank? }
  validates :ss_hex_digest, absence: true,
                            unless: proc { |debtor_ex| debtor_ex.employer_id_number.blank? }
  validates :employer_id_number,  uniqueness: true,
                                  unless: proc { |debtor_ex| debtor_ex.employer_id_number.blank? }
  validates :ss_hex_digest,       uniqueness: true,
                                  unless: proc { |debtor_ex| debtor_ex.ss_hex_digest.blank? }
  validates :employer_id_number,  format: { with: VALID_EIN_REGEX,
                                            message: I18n.t('validation_error.must_be_valid_ein') }
  validates :ss_hex_digest,       format: { with: VALID_SS_REGEX,
                                            message: I18n.t('validation_error.must_be_valid_ss') }

  ## Methods
  def self.search(search_term, sort_order="debtor.id desc")
    search_term = clean_up_search_term(search_term)
    term_class = search_term.class

    if term_class == Integer
      where('employer_id_number LIKE ?', "%#{search_term}%").order(sort_order)
    elsif term_class == HexString # For API
      where('ss_hex_digest LIKE ?', "%#{search_term}%").order(sort_order)
    elsif term_class == String
      where('LOWER(name) LIKE ? OR employer_id_number LIKE ? OR email LIKE ?',
            "%#{search_term}%", "%#{search_term}%", 
            "%#{search_term}%").order(sort_order)
    else
      fail I18n.t('flash.debtor_search_failed')
    end
  end

  def self.clean_up_search_term(search_term)
    # This method is tightly coupled
    case search_term
    when /\A([[:digit:]]{3}-[[:digit:]]{2}-[[:digit:]]{4})\z/
      # if name keep string
      DebtorsHelper::HexString.new(Debtor.encrypt(search_term)) # or Encrypt(search_term)
    when /\A([0-9]{2}-[0-9]{7})\z/ # REGEX for EIN
      # if ein turn to int
      Debtor.remove_hyphens(search_term).to_i
    when /\A[[:xdigit:]]+\z/i
      # if ss turn to hexstring
      HexString.new search_term.to_s.downcase
    else
      # else String
      search_term.to_s.downcase
    end
  end

  ## Helper Methods
  def self.remove_hyphens(term)
    term.to_s.each_char.select { |x| x.match(/[0-9]/) }.join('')
  end

  def self.encrypt(token)
    Digest::SHA1.hexdigest(Debtor.salt(Debtor.remove_hyphens(token)).to_s)
  end

  def self.salt(token, salt = Rails.application.secrets.salt)
    # salt stored in secrets.yml
    fail(ArgumentError, 'Nil propagation, token not set', caller) if token.nil?
    fail(ArgumentError, 'Rails Salt (config/secret.yml) not set', caller) if salt.nil?

    token.to_i + salt
  end

  def self.guard_length(token, length = 9)
    fail unless token.to_s.split('').size == length
  end
end
# Debtor.includes(:debts).group('debts.pending_balance').order('debts.id DESC').references(:debts)
# Debtor.includes(:debts).order('debts.id DESC').references(:debts)
# Debtor.joins(:debts).order("debts.pending_balance desc") # how to count
# Debtor.joins(:debts).order("COUNT(debts.pending_balance) desc")
# Debtor.joins(:debts).order(Arel.sql("COUNT(debts.pending_balance) desc"))
# Debtor.joins(:debts).group('debts.pending_balance').order(Arel.sql("COUNT(debts.pending_balance) desc")).references(:debts)