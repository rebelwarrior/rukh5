class CreateNoops < ActiveRecord::Migration[5.2]
  def change
    create_table :noops do |t|

      t.timestamps
    end
  end
end
