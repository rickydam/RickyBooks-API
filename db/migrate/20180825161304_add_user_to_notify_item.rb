class AddUserToNotifyItem < ActiveRecord::Migration[5.2]
  def change
    add_reference :notify_items, :user, foreign_key: true
  end
end
