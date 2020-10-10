class CreateNoopToos < ActiveRecord::Migration[5.2]
  def change
    create_table :noop_toos do |t|

      t.timestamps
    end
  end
end
