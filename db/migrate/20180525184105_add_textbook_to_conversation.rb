class AddTextbookToConversation < ActiveRecord::Migration[5.2]
  def change
    add_reference :conversations, :textbook, foreign_key: true
  end
end
