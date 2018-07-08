class AddFileExtensionToImages < ActiveRecord::Migration[5.2]
  def change
    add_column :images, :file_extension, :string
  end
end
