class CreateDequeuedMessages < ActiveRecord::Migration
  def change
    create_table :dequeued_messages do |t|
      t.text :body

      t.timestamps
    end
  end
end
