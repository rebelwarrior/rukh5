require 'rails_helper'

require "import_logic2"

describe FindFileLines do 
  let(:find_lines_obj) { FindFileLines.new }
  
  it "calculates the number of lines in a stringIO / opened file" do 
    opened_file = StringIO.new("1\n2\n")
    lines = find_lines_obj.find_number_lines(opened_file)
    expect(lines).to eq(2)
  end
  
end

describe CheckEncoding do
  let(:check_encoding_obj) { CheckEncoding.new }

  it 'guesses the right encoder' do
    # opened_file = StringIO.new("hello")
    encoding = check_encoding_obj.check_encoding("hello")
    expect(encoding).to eq("ASCII")
  end

end