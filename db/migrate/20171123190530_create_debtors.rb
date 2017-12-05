class CreateDebtors < ActiveRecord::Migration[5.1]
  def change
    create_table :debtors do |t|
      t.string :name
      t.string :email
      t.string :tel
      t.string :ext
      t.string :address
      t.string :location
      t.string :employer_id_number
      t.string :ss_hex_digest

      t.timestamps
    end
  end
end
