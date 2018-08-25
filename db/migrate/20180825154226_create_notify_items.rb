class CreateNotifyItems < ActiveRecord::Migration[5.2]
  def change
    create_table :notify_items do |t|
      t.string :category
      t.string :input

      t.timestamps
    end
  end
end
