require 'sucker_punch'
require 'cmess/guess_encoding'
require 'smarter_csv'
require 'import_support'
require 'import_logic3'

# Contains the logic for importing CSV files to the db. 
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

# Finds the number of lines in a file.
class FindFileLines
  include SuckerPunch::Job

  def perform(file)
    ## Open Files and Counts Lines
    file.open { |opened_file| find_number_lines(opened_file) }
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

# Guesses the Character Encoding of the file. 
class CheckEncoding
  include SuckerPunch::Job

  def perform(file)
    ## Guesses Encoding of File then returns string with encoding.
    input = File.read(file)
    CMess::GuessEncoding::Automatic.guess(input)
  end
end

# Once the encoding is known and the lines it processes the CSV in chunks. 
class ProcessCSV
  include SuckerPunch::Job
  def perform(file, _file_lines, char_set)
    counter = []
    ActiveRecord::Base.connection_pool.with_connection do
      ActiveRecord::Base.transaction do
        SmarterCSV.process(file,
                           chunk_size: 10,
                           verbose: true,
                           file_encoding: char_set.to_s) do |file_chunk|
          file_chunk.each do |record_row|
            sanitized_row = ImportSupport.sanitize_hash(record_row)
            StoreRecord.new.perform(sanitized_row)
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
