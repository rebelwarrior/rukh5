# Module with methods to support the Import Action
module ImportSupport
  module_function

  def import_key_array(model, extra = [])
    model.attribute_names - %w[created_at updated_at] + extra
  end

  def debt_headers_array
    ## Default keys for Debt
    %i[
      id
      permit_infraction_number
      amount_owed_pending_balance
      paid_in_full
      type_of_debt
      original_debt_date
      originating_debt_amount
      bank_routing_number
      bank_name
      bounced_check_number
      in_payment_plan
      in_administrative_process
      contact_person_for_transactions
      notes
      debtor_id
      fimas_project_id fimas_budget_reference
      fimas_class_field fimas_program
      fimas_fund_code fimas_account fimas_id
    ]
  end

  def debtor_headers_array
    ## Default keys for Debtor
    %i[id employer_id_number name tel email address location contact_person]
  end

  def delete_all_keys_except(hash_record, except_array = [])
    ## To clean up a hash with only permited keys
    hash_record.select do |key|
      except_array.include?(key) or except_array.include?(key.to_s)
    end
  end

  def sanitize_hash(dirty_hash)
    ## Exchanges `/` for `-` then removes everything not[^ ] :word or - or . or space or @
    dirty_hash.transform_values do |dirty_string|
      dirty_string.to_s.gsub(%r{/}, '-').gsub(/[^ [:word:]\-\.\@ ]/i, '')
    end
  end

  def add_missing_keys(hash_record, keys_array = [], default_value = '')
    ## Adds missing keys from array, sets empty ones to an empty string.
    keys_only_hash = keys_array.zip(Array.new(keys_array.size, default_value)).to_h
    keys_only_hash.merge(hash_record)
  end

  def remove_nil_from_hash(hash_record, substitute_value = '')
    ## Removes nil from a hash values and replaces it with new value
    ## Method keeps key simply replaces nil. Should be renamed.
    if hash_record.value?(nil)
      hash_record.transform_values do |value|
        value.nil? ? substitute_value : value
      end
    else
      hash_record
    end
  end

  ## TODO define IMPORT ERROR here
  class ImportError < RuntimeError
  end
end
