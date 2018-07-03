class AddTextbookToImage < ActiveRecord::Migration[5.2]
  def change
    add_reference :images, :textbook, foreign_key: true
  end
end
