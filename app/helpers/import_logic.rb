require 'sucker_punch'
require 'cmess/guess_encoding'
require 'smarter_csv'
require 'import_support'

class ImportLogic
  def self.import_csv(file)
    file_lines = FindFileLines.new.perform(file)
    char_set   = CheckEncoding.new.perform(file.tempfile)
    start_time = Time.now.to_i
    ProcessCSV.new.perform(file.tempfile, file_lines, char_set)
    finish_time = Time.now.to_i
    [file_lines, (finish_time - start_time)]
  end
end

class FindFileLines
  include SuckerPunch::Job

  def perform(file)
    ## Open Files and Counts Lines
    file.open { |f| find_number_lines(f) }
  end

  def find_number_lines(opened_file)
    ## Finds Total lines of Opened File and Rewinds File
    total_lines = opened_file.each_line.inject(0) do |total, _amount|
      total + 1
    end
    opened_file.rewind
    total_lines
  end
end

class CheckEncoding
  include SuckerPunch::Job

  def perform(file)
    ## Guesses Encoding of File then returns string with encoding.
    input = File.read(file)
    CMess::GuessEncoding::Automatic.guess(input)
  end
end

class ProcessCSV
  include SuckerPunch::Job
  
  # rubocop:disable Metrics/AbcSize
  def perform(file, file_lines, char_set)
    counter = []
    ActiveRecord::Base.connection_pool.with_connection do
      ActiveRecord::Base.transaction do
        SmarterCSV.process(file,
                           chunk_size: 10,
                           verbose: true,
                           file_encoding: char_set.to_s) do |file_chunk|
          file_chunk.each do |record_row|
            sanitized_row = ImportSupport.sanitize_hash(record_row)
            StoreRecord.new.perform(sanitized_row, {})
            # appends in latest record to allow error to report where import failed
            counter << sanitized_row 
            puts "\033[32m#Processed Record No. #{counter.size}.\033[0m\n"
            counter
          end
        end
      end
      ## Run Job here for Progress Bar
    end
  end
end

class StoreRecord
  # Refactor: This Stores record. 
  include SuckerPunch::Job

  # def debtor_id_process(record, debtor_id, debt_id)
  #   ## Store record when Debtor in already in db.
  #   if !record.fetch(:id).strip.downcase['null'] &&
  #      Debt.find_by(id: debt_id)
  #     ## Update action overwrites
  #     ## Update Debt
  #     record[:debtor_id] = debtor_id.to_i
  #     update_debt_record(record, update: true, id: debt_id)
  #   elsif !record.fetch(:id).strip.downcase['null']
  #     record[:debtor_id] = debtor_id.to_i
  #     store_debt_record(record)
  #   else
  #     # TODO: change fails into Flash message by using ImportError
  #     fail ImportSupport::ImportError, "Can't Update Record without matching IDs"
  #   end
  # end

  # @@debt_headers_array = ImportSupport.debt_headers_array
  # @@debtor_headers_array = ImportSupport.debtor_headers_array

  def debt_headers_array
    ImportSupport.debt_headers_array
  end

  def debtor_headers_array
    ImportSupport.debtor_headers_array
  end

  def store_debt_record(record, debt_array = debt_headers_array)
    store_one_record(record, debt_array, Debt)
  end

  def update_debt_record(record, id, debt_array = debt_headers_array)
    store_one_record(record, debt_array, Debt, update: true, id: id, debt: true)
  end

  def store_debtor_record(record, debtor_array = debtor_headers_array)
    store_one_record(record, debtor_array, Debtor) do |debtor_record|
      debtor_record[:contact_person] = debtor_record[:name]
    end
  end

  def store_one_record(record, inc_array, model, options = { create: true }, &block)
    #TODO refactor
    clean_record = ImportSupport.delete_all_keys_except(record, inc_array)
    # id = record.fetch(:id).to_i
    yield(clean_record) if block
    if options[:create]
      model.create(clean_record)
    elsif options[:update]
      id = if options[:debt]
             record[:id]
           else
             record[:debtor_id]
           end
      # up_record = {id => clean_record}
      model.update(id, clean_record)
    else
      fail ImportSupport::ImportError, 'No valid option given'
    end
    # if succeeds...
  end
  
  def store_single_record(record, model, options = {create: true}, &block)
    yield record if block
    
    if options[:create]
      stored = model.create(record)
    elsif options[:update]
      #TODO create method 
      fail "missing method update model"
    else
      fail ImportSupport::ImportError, 'No valid option given'
    end
    stored.id
  end

  # def debtor_in_db_already(record, db_Debtor = Debtor)
  #   ## 'Verifies if record contains a debtor already in db'
  #   ## returns 0 (if not found) or debtor id (integer) if found.
  #   if record[:debtor_id] &&
  #      record[:debtor_id].strip.casecmp('null').zero? &&
  #      db_Debtor.find_by(id: record.fetch(:debtor_id))
  #     puts 'Searching db by ID'
  #     db_Debtor.find(record.fetch(:debtor_id))
  #   else
  #     check_debtor_via_name_ein(record, db_Debtor)
  #   end
  # end

  # def check_debtor_via_name_ein(record, db_Debtor = Debtor)
  #   # TODO Refactor
  #   # Returns Debtor id if found else returns 0.
  #   if record[:employer_id_number]
  #     debtor_by_ein = db_Debtor.find_by employer_id_number: record.fetch(:employer_id_number)
  #   else
  #     debtor_by_ein = nil
  #   end
  #
  #   if debtor_by_ein
  #     puts "Searching db by EIN (Employer ID Number): #{record[:employer_id_number]}"
  #     debtor_by_ein.id
  #   elsif record[:debtor_name]
  #     puts "Searching db for debtor by NAME for #{record[:debtor_name]}"
  #     search_debtor_db_by_name(record.fetch(:debtor_name), db_Debtor)
  #   else
  #     0
  #   end
  # end

  # def search_debtor_db_by_name(name_string, db_Debtor = Debtor)
  #   # Returns 0 if debtor not found otherwise returns debtor id.
  #   return 0 if name_string.strip.casecmp('null').zero?
  #   debtor = db_Debtor.find_by name: name_string
  #   if debtor.blank?
  #     0
  #   else
  #     debtor.id
  #   end
  # end
  
  def search_by_ein(record, db_Debtor = Debtor)
    # Returns nil if debtor not found otherwise returns debtor
    return nil unless record[:employer_id_number]
    db_Debtor.find_by employer_id_number: record.fetch(:employer_id_number)
  end
  
  def search_by_name(record, db_Debtor = Debtor)
    # Returns nil if debtor not found otherwise returns debtor
    return nil if name_string.strip.casecmp('null').zero?
    db_Debtor.find_by name: name_string
  end
  
  def search_by_id(record, db_Debtor = Debtor)
    # Returns nil if debtor not found otherwise returns debtor
    return nil unless record[:debtor_id]
    return nil unless record[:debtor_id].strip.casecmp('null').zero?
    db_Debtor.find_by(id: record.fetch(:debtor_id))
  end
  
  def find_debtor_id(record, db_Debtor = Debtor)
    # Returns debtor_id or zero if not found.
    debtor = search_debtor_id(record, db_Debtor)
    debtor ? debtor.id : 0 
  end
  
  def search_debtor_id(record, db_Debtor = Debtor)
    # Returns debtor or nil
    search_by_id(record, db_Debtor) or
    search_by_ein(record, db_Debtor) or 
    search_by_name(record, db_Debtor) or 
    nil
  end
  
  def debtor_record(record)
    debtor_record = ImportSupport.add_missing_keys(record, 
                    ImportSupport.debtor_headers_array)
    ImportSupport.remove_nil_from_hash(debtor_record, '')
  end

  def perform(record)
    # debtor_id = debtor_in_db_already(record)
    debtor_id = find_debtor_id(record)
    debt_id   = record.fetch(:id, 0).to_i 
    inc_array = ImportSupport.import_key_array(Debt, ["debtor_name"])
    clean_record = ImportSupport.delete_all_keys_except(record, inc_array)

    if !debtor_id.zero? && debt_id.zero?
      # Create new debt for existing debtor.
      create_new_debt(clean_record, debtor_id)
      # debtor_id_process(record, debtor_id, debt_id)
    elsif debtor_id.zero? && debt_id.zero?
      # Create new debt and new debtor
      create_new_debtor(clean_record) 
      create_new_debt(clean_record, debtor_id)
    elsif !debtor_id.zero? && !debt_id.zero?
      # Update existing debt for existing debtor.
      fail "no implemented yet"
      
    elsif record[:debtor_id] && debtor_id.nil?
      fail "should not see this"
      ## DONE: merge hash to add missing keys
      ## DONE # debtor_record = add_missing_keys(record, debtor_array)
      debtor_record = ImportSupport.add_missing_keys(record, ImportSupport.debtor_headers_array)
      ## DONE: Blank out nil values to empty strings:
      debtor_record = ImportSupport.remove_nil_from_hash(debtor_record, '')

      # debtor_record = record ## old

      ## Store Debtor
      debtor_record[:name] = record[:debtor_name]
      # TODO: Debtor update not working.
      debtor = store_debtor_record(debtor_record)

      ## Store Debt
      record[:debtor_id] = debtor.id
      store_debt_record(record)
    else
      # TODO: change fails into Flash message by using ImportError
      fail ImportSupport::ImportError, "Can't understand import record: #{record}"
    end
  end
  
  def create_new_debt(record, debtor_id)
    record[:debtor_id] = debtor_id
    # store_debt_record(record)
    store_single_record(record, Debt, {create: true})
  end
  
  def create_new_debtor(record, db_Debtor = Debtor) 
    # Refactor
    fail "not implemented yet new debtor"
    # debtor = Debtor.create {name: record[:debtor_name]} #Contact name?
    # debtor.id
    store_single_record({name: record[:debtor_name]}, Debtor, {create: true})
  end
end
