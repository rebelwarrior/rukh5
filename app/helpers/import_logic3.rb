require 'sucker_punch'
require 'cmess/guess_encoding'
require 'smarter_csv'
require 'import_support'

# Class that stores records using threads
class StoreRecord
  # Refactor: This Stores record.
  include SuckerPunch::Job

  def search_by_term(record, term, debtor_model = Debtor)
    # Returns nil if debtor not found otherwise returns debtor
    return nil unless record[term]
    return nil if record[term].strip.casecmp('null').zero?

    debtor_model.find_by term record.fetch(term)
  end

  # def search_by_ein(record, debtor_model = Debtor)
  #   search_by_something(record, :employer_id_number, debtor_model)
  # end

  def search_by_ein(record, debtor_model = Debtor)
    # Returns nil if debtor not found otherwise returns debtor
    return nil unless record[:employer_id_number]
    return nil if record[:employer_id_number].strip.casecmp('null').zero?

    debtor_model.find_by employer_id_number: record.fetch(:employer_id_number)
  end

  def search_by_name(record, debtor_model = Debtor)
    # Returns nil if debtor not found otherwise returns debtor
    return nil unless record[:debtor_name]
    return nil if record[:debtor_name].strip.casecmp('null').zero?

    debtor_model.find_by(name: record.fetch(:debtor_name))
  end

  def search_by_id(record, debtor_model = Debtor)
    # Returns nil if debtor not found otherwise returns debtor
    return nil unless record[:debtor_id]
    return nil if record[:debtor_id].strip.casecmp('null').zero?

    debtor_model.find_by(id: record.fetch(:debtor_id))
  end

  def search_debtor_id(record, debtor_model = Debtor)
    # Returns debtor or nil
    search_by_id(record, debtor_model) or
      search_by_ein(record, debtor_model) or
      search_by_name(record, debtor_model) or
      nil
  end

  def find_debtor_id(record, debtor_model = Debtor)
    # Returns debtor_id or zero if not found.
    debtor = search_debtor_id(record, debtor_model)
    debtor ? debtor.id : 0
  end

  def store_single_record(cleaned_record, model, options = { create: true }, &block)
    yield cleaned_record if block

    if options[:create]
      stored = model.create([cleaned_record])
    elsif options[:update]
      # TODO: test update method
      fail ImportSupport::ImportError, "Update not implemented"
      # stored = model.update(cleaned_record)
    else
      fail ImportSupport::ImportError, 'No valid option given'
    end
    # Stored is an array of the created objects.
    stored.at(0)
  end

  def debtor_record(record)
    debtor_record =
      ImportSupport.add_missing_keys(record,
                                     ImportSupport.debtor_headers_array)
    ImportSupport.remove_nil_from_hash(debtor_record, '')
  end

  def perform(record)
    debtor_id = find_debtor_id(record)
    debt_id   = record.fetch(:id, 0).to_i
    inc_array =    ImportSupport.import_key_array(Debt, ["debtor_name"])
    clean_record = ImportSupport.delete_all_keys_except(record, inc_array)

    store_or_update_record(debtor_id, debt_id, clean_record)
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def store_or_update_record(debtor_id, debt_id, clean_record)
    debtor_id_zero = debtor_id.zero?
    debt_id_zero   = debt_id.zero?

    existing_debtor_with_new_debt      = !debtor_id_zero && debt_id_zero
    new_debtor_with_new_debt           = debtor_id_zero && debt_id_zero
    existing_debtor_with_existing_debt = debtor_id_zero && !debtor_id_zero

    if existing_debtor_with_new_debt
      # Create new debt for existing debtor.
      create_new_debt(clean_record, debtor_id)
    elsif new_debtor_with_new_debt
      # Create new debt and new debtor
      create_new_debt(clean_record, create_new_debtor(clean_record).id)
    elsif existing_debtor_with_existing_debt
      # Update existing debt for existing debtor.
      update_debtor(clean_record) && update_debt(clean_record)
    else
      fail ImportSupport::ImportError, "Can't understand import record: #{clean_record}"
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  ## Incomplete Methods ##
  # The methods below all involve hacks to add or remove keys
  # TODO refactor these to be more systematic.

  # These can all be utility functions

  def create_new_debt(record, debtor_id, debt_model = Debt)
    # Record must be cleaned otherwise extra parameters cause havok
    record[:debtor_id] = debtor_id
    record.delete :debtor_name
    record.delete :id
    store_single_record(record, debt_model, create: true)
  end

  def update_debt(_record, debt_model = Debt)
    record[:debtor_id] = debtor_id
    record.delete :debtor_name
    record.delete :id
    store_single_record(record, debt_model, create: false, update: true)
  end

  def update_debtor(record, debtor_model = Debtor)
    update_record = { name: record[:debtor_name], id: record[:debtor_id] }
    store_single_record(update_record, debtor_model, create: false, update: true)
  end

  def create_new_debtor(record, debtor_model = Debtor)
    store_single_record({ name: record[:debtor_name] }, debtor_model, create: true)
  end
end
