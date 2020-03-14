class Debt < ApplicationRecord
  # TODO: create migration to prevent nulls on originating debt
  belongs_to :debtor, touch: true

  ## Regular Expressions for Validations
  VALID_NUM_REGEX = /\A[[:digit:]]+\.?[[:digit:]]*\z/.freeze
  VALID_PERMIT_REGEX = \
    /[[:alpha:]]{2}-?[[:alpha:]]{2}-?[0-9]{2}-?[0-9]{2}-?[0-9]{2}-?[0-9]{1}/i.freeze
  VALID_INFRACTION_REGEX = /[[:alpha:]]-?[0-9]{2}-?[0-9]{2}-?[0-9]{3}-?[[:alpha:]]{2}/i.freeze
  VALID_PERMIT_OR_INFRACTION_REGEX = \
    /\A#{VALID_INFRACTION_REGEX}|#{VALID_PERMIT_REGEX}\z/.freeze
  VALID_DATE_REGEX = \
    %r~\A([0-9]{1,2}(\/?|-?)[0-9]{1,2}(\/?|-?)[0-9]{4}|[0-9]{4}(\/?|-?)[0-9]{1,2}(\/?|-?)[0-9]{1,2})\z~
    .freeze
  VALID_ROUTING_NUM_REGEX = /(\A\z|\A[0-9]{9}\z)/.freeze

  ## Validations
  validates :debtor_id,          presence: true
  validates :incurred_debt_date, presence: true,
                                 format: { with: VALID_DATE_REGEX,
                                           message: I18n.t('validation_error.must_be_date') }
  validates :pending_balance, format: { with: VALID_NUM_REGEX,
                                        message: I18n.t('validation_error.must_be_num') }
  # validates :bounced_check_number,format: { with: /\A[[:digit:]]*\z/i,
  #                           message: I18n.t('validation_error.must_be_num') }
  validates :infraction_number, format: { with: /\A#{VALID_INFRACTION_REGEX}\z/,
                                          message: I18n.t('validation_error.must_be_infraction_num') },
                                unless: proc { |debt_ex| debt_ex.infraction_number.blank? }

  ## Methods
  # TODO refactor:
  def find_debtor_attr(debtor_id, attributes)
    result = []
    debtor = Debtor.find_by(id: debtor_id)
    attributes.each do |attribute|
      attribute_clean = { name: :name, contact: :contact_person }.fetch(attribute)
      result << (debtor.nil? ? 'NULL' : debtor.public_send(attribute_clean))
    end
    result
  end

  ## Export to CSV
  ## Calls to_plan_csv w/ extra column names
  def self.to_csv
    to_plain_csv(%i[debtor_name]) do |extra_items, record|
      extra_items.push(record.find_debtor_attr(record.attributes['debtor_id'], %i[name]))
    end
  end

  ## Export to Plain CSV.
  def self.to_plain_csv(extra_column_names = [], options = {}, &block)
    require 'csv'
    CSV.generate(options) do |csv|
      csv.add_row(column_names + extra_column_names)
      all.find_each do |record|
        extra_items = []
        yield(extra_items, record) if block
        csv.add_row record.attributes.values_at(*column_names).concat(extra_items).flatten
      end
    end
  end
end
