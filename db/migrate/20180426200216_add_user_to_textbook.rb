class AddUserToTextbook < ActiveRecord::Migration[5.2]
  def change
    add_reference :textbooks, :user, foreign_key: true
  end
end
