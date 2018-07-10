class AddUrlCreatedAtToImages < ActiveRecord::Migration[5.2]
  def change
    add_column :images, :url_created_at, :string
  end
end
