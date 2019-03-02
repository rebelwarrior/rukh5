require 'sucker_punch'
require 'cmess/guess_encoding'
require 'smarter_csv'
require 'import_support'

# Class that stores records using threads
class StoreRecord
  # Refactor: This Stores record.
  include SuckerPunch::Job
  
  def search_by_something(record, something, db_Debtor = Debtor)
    # Returns nil if debtor not found otherwise returns debtor
    return nil unless record[something]
    return nil if record[something].strip.casecmp('null').zero?
    db_Debtor.find_by something record.fetch(something)
  end
  
  # def search_by_ein(record, db_Debtor = Debtor)
  #   search_by_something(record, :employer_id_number, db_Debtor)
  # end

  def search_by_ein(record, db_Debtor = Debtor)
    # Returns nil if debtor not found otherwise returns debtor
    return nil unless record[:employer_id_number]
    return nil if record[:employer_id_number].strip.casecmp('null').zero?
    db_Debtor.find_by employer_id_number: record.fetch(:employer_id_number)
  end

  def search_by_name(record, db_Debtor = Debtor)
    # Returns nil if debtor not found otherwise returns debtor
    return nil unless record[:debtor_name]
    return nil if record[:debtor_name].strip.casecmp('null').zero?
    db_Debtor.find_by(name: record.fetch(:debtor_name))
  end

  def search_by_id(record, db_Debtor = Debtor)
    # Returns nil if debtor not found otherwise returns debtor
    return nil unless record[:debtor_id]
    return nil if record[:debtor_id].strip.casecmp('null').zero?
    db_Debtor.find_by(id: record.fetch(:debtor_id))
  end

  def search_debtor_id(record, db_Debtor = Debtor)
    # Returns debtor or nil
    search_by_id(record, db_Debtor) or
      search_by_ein(record, db_Debtor) or
      search_by_name(record, db_Debtor) or
      nil
  end

  def find_debtor_id(record, db_Debtor = Debtor)
    # Returns debtor_id or zero if not found.
    debtor = search_debtor_id(record, db_Debtor)
    debtor ? debtor.id : 0
  end

  def store_single_record(cleaned_record, model, options = { create: true }, &block)
    yield cleaned_record if block

    if options[:create]
      stored = model.create([cleaned_record])
    elsif options[:update]
      # TODO: test update method
      fail ImportSupport::ImportError, "Update not implemented"
      stored = model.update(cleaned_record)
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

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def perform(record)
    debtor_id = find_debtor_id(record)
    debt_id   = record.fetch(:id, 0).to_i
    inc_array =    ImportSupport.import_key_array(Debt, ["debtor_name"])
    clean_record = ImportSupport.delete_all_keys_except(record, inc_array)

    if !debtor_id.zero? && debt_id.zero?
      # Create new debt for existing debtor.
      create_new_debt(clean_record, debtor_id)
    elsif debtor_id.zero? && debt_id.zero?
      # Create new debt and new debtor
      new_debtor = create_new_debtor(clean_record)
      create_new_debt(clean_record, new_debtor.id)
    elsif !debtor_id.zero? && !debt_id.zero?
      # Update existing debt for existing debtor.
      update_debtor(clean_record)
      update_debt(clean_record)
    else
      # TODO: change fails into Flash message by using ImportError
      fail ImportSupport::ImportError, "Can't understand import record: #{record}"
    end
  end

  ## Incomplete Methods ##
  # The methods below all involve hacks to add or remove keys
  # TODO refactor these to be more systematic.

  def create_new_debt(record, debtor_id, db_Debt = Debt)
    # Record must be cleaned otherwise extra parameters cause havok
    record[:debtor_id] = debtor_id
    record.delete :debtor_name
    record.delete :id
    store_single_record(record, db_Debt, create: true)
  end

  def update_debt(_record, db_Debt = Debt)
    record[:debtor_id] = debtor_id
    record.delete :debtor_name
    record.delete :id
    store_single_record(record, db_Debt, create: false, update: true)
  end

  def update_debtor(record, db_Debtor = Debtor)
    update_record = { name: record[:debtor_name], id: record[:debtor_id] }
    store_single_record(update_record, db_Debtor, create: false, update: true)
  end

  def create_new_debtor(record, db_Debtor = Debtor)
    store_single_record({ name: record[:debtor_name] }, db_Debtor, create: true)
  end
end
