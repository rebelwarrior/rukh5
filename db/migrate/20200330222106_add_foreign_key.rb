class AddForeignKey < ActiveRecord::Migration[5.2]
  def change 
    add_foreign_key :debts, :debtor_id 
  end
end
