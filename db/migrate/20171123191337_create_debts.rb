class CreateDebts < ActiveRecord::Migration[5.1]
  def change
    create_table :debts do |t|
      t.decimal :pending_balance
      t.decimal :original_balance
      t.date :incurred_debt_date
      t.boolean :in_payment_plan
      t.integer :debtor_id
      t.string :infraction_number
      t.integer :fimas_id

      t.timestamps
    end
  end
end
