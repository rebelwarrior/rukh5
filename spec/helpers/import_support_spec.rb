# spec/helpers/import_support_spec.rb 

require 'rails_helper'

describe ImportSupport do 
  it 'removes nil without removing the key' do 
    dirty_hash = { a: 'a', b: nil}
    clean_hash = { a: 'a', b: ''}
    expect(ImportSupport.remove_nil_from_hash(dirty_hash)).to eq(clean_hash)
  end
  it 'adds missing keys' do
    keys_array = ['a', 'b', :c, :b ]
    hash_record = { a: 1, b: 2}
    result = 
      ImportSupport.add_missing_keys(hash_record, keys_array)
    expect(result).to eq({:a=>1, :b=>2, :c=>"", "a"=>"", "b"=>""})
  end
  it 'cleans up a dirty hash' do 
    dirty_hash = {a: "We're at &the <begining> $of-the @world.", b: "clean"}
    clean_hash = {a: "Were at the begining of-the @world.", b: "clean"}
    expect(ImportSupport.sanitize_hash(dirty_hash)).to eq(clean_hash)
  end
  it 'imports key array from model removes "created_at" "updated_at" & adds extra' do
    model = Struct.new(:null) do 
      def attribute_names
        %w[created_at updated_at name id]
      end
    end.new(nil)
    import_array = ImportSupport.import_key_array(model, ["extra"])
    expect(import_array).to eq(["name", "id", "extra"])
  end  
end
