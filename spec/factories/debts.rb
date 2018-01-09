FactoryBot.define do
  factory :debt do
    association :debtor
    sequence(:id) { |n| n }
    infraction_number { "M-12-12-#{rand(100..999)}-RC" }
    pending_balance { rand(12).to_s }
    incurred_debt_date { "#{rand(1980..2014)}-#{rand(1..12)}-#{rand(1..28)}" }
    original_balance { rand(12).to_s }
    in_payment_plan false
    created_at { Date.yesterday }
    updated_at { Date.today }
    sequence(:fimas_id) { |n| n }
  end
end
