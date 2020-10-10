class CreateNoopThrees < ActiveRecord::Migration[5.2]
  def change
    create_table :noop_threes do |t|

      t.timestamps
    end
  end
end
