require 'rails_helper'

# require "FindFileLines"
require "import_logic2"

describe FindFileLines do 
  # let(:csv_test_file) { File.expand_path('./spec/helpers/test.csv') }
  
  # it "calculates the number of lines in a file" do
  #   lines = FindFileLines.new.perform(csv_test_file)
  #   expect(lines).to eq(3)
  # end
  
  it "calculates the number of lines in a stringIO / opened file" do 
    opened_file = StringIO.new("1\n2\n")
    lines = FindFileLines.new.find_number_lines(opened_file)
    expect(lines).to eq(2)
    
  end
  
end