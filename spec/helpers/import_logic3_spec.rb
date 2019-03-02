require 'rails_helper'

require "import_logic3"


class ModelDouble 
  
  def initialize()
  end
  
  def create(arr_hash) 
    arr_hash = hash[0]
    model = Struct.new(*hash.keys)
    @model = model.new(*hash.values)
  end
end

describe StoreRecord do 
  
  it "store_single_record" do 
    cleaned_record = {id: 0, name: "Pepito", nested: { a: "inside"}}
    model = ModelDouble.new 
    StoreRecord.new.store_single_record(cleaned_record, model)
    puts cleaned_record
    expect(model.to_h).to eq(cleaned_record)
  end
  
end