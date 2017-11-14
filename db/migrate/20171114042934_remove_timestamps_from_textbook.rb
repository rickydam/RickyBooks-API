class RemoveTimestampsFromTextbook < ActiveRecord::Migration[5.1]
  def change
    remove_column :textbooks, :updated_at, :string
  end
end
