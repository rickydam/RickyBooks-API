class CreateTextbooks < ActiveRecord::Migration[5.2]
  def change
    create_table :textbooks do |t|
      t.string :textbook_title
      t.string :textbook_author
      t.string :textbook_edition
      t.string :textbook_condition
      t.string :textbook_type
      t.string :textbook_coursecode
      t.string :textbook_price

      t.timestamps
    end
  end
end
