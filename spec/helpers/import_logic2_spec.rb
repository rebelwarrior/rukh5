require 'rails_helper'

require "import_logic2"

describe FindFileLines do 
  # let(:csv_test_file) { File.expand_path('./spec/helpers/test.csv') }
  let(:find_lines_obj) { FindFileLines.new }
  
  # it "calculates the number of lines in a file" do
  #   lines = find_lines_obj.perform(csv_test_file)
  #   expect(lines).to eq(3)
  # end
  
  it "calculates the number of lines in a stringIO / opened file" do 
    opened_file = StringIO.new("1\n2\n")
    lines = find_lines_obj.find_number_lines(opened_file)
    expect(lines).to eq(2)
    
  end
  
end