class CreateOperations < ActiveRecord::Migration
  def change
    create_table :operations do |t|
      t.datetime :begin_time
      t.datetime :end_time
      t.string :engine
      t.string :action
      t.integer :nbr_messages

      t.timestamps
    end
  end
end
