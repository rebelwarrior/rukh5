require 'rails_helper'

require "import_logic3"


class ModelDouble 
  
  def initialize()
  end
  
  def create(arr_hash) 
    @model = arr_hash[0] #= hash[0]
  end

  def to_h
    @model
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