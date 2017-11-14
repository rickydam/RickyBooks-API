class RenameCreatedAtToCreated < ActiveRecord::Migration[5.1]
  def change
    rename_column :textbooks, :created_at, :created
  end
end
