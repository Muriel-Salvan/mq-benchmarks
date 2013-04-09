class AddEngineToDequeuedMessages < ActiveRecord::Migration
  def change
    add_column :dequeued_messages, :engine, :string
  end
end
