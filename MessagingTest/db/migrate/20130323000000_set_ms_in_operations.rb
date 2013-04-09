class SetMsInOperations < ActiveRecord::Migration
  def change
    add_column :operations, :elapsed_time, :string
    remove_column :operations, :begin_time
    remove_column :operations, :end_time
  end
end
