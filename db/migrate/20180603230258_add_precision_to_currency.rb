class AddPrecisionToCurrency < ActiveRecord::Migration[5.1]
  def change
    change_column :debts, :pending_balance, :decimal, :precision => 8, :scale => 2
    change_column :debts, :original_balance, :decimal, :precision => 8, :scale => 2
  end
end
