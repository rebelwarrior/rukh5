require 'faker'

FactoryBot.define do
  factory :debtor do
    name { Faker::Name.name }
    email { Faker::Internet.safe_email }
    tel '787-761-6767'
    ext "x#{Faker::PhoneNumber.extension}"
    address { "#{Faker::Address.street_address}, #{Faker::Address.city}, #{Faker::Address.zip}" }
    location { "#{Faker::Address.street_name}, #{Faker::Address.secondary_address}" }
    employer_id_number { Faker::Company.ein }
    ss_hex_digest ''
  end
end

=begin
create_table "debtors", force: :cascade do |t|
  t.string "name"
  t.string "email"
  t.string "tel"
  t.string "ext"
  t.string "address"
  t.string "location"
  t.string "employer_id_number"
  t.string "ss_hex_digest"
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
end
=end