require 'rails_helper'

require 'debtors_helper'

describe DebtorsHelper do 
  
  it "displays telephone in format" do 
    string = '1234567890'
    result = display_tel(string)
    expect(result).to eq('(123)456-7890')
  end
  
  it "displays the extension in format" do 
    expect("ext: abc ").to eq(display_ext('abc'))
  end
  
end

describe DebtorsBackendHelper do 
  
  it 'removes hyphens' do 
    term = "123-456"
    result = DebtorsBackendHelper::remove_hyphens_from_numbers(term)
    expect(result).to eq("123456")
  end
  
  it 'salt works' do 
    salted = DebtorsBackendHelper::salt("1234", 101)
    expect(salted).to eq(1335)
  end
  
  it 'encrypts and salts' do
    digester = Struct.new("Digester") do 
      def hexdigest(i); i; end
    end.new
    token = "123-4"
    encrypted = DebtorsBackendHelper::encrypt(token, digester, 101)
    expect(encrypted).to eq("1335")
  end
  
  it "guard_length" do
    error_msg = "Not proper length: 4. Expected 3."
    expect { DebtorsBackendHelper::guard_length("1234", 3) }.to raise_error(error_msg)
  end
  
end