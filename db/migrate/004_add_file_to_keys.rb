class AddFileToKeys < ActiveRecord::Migration[4.2]
  def change
    add_column :keys, :file, :string
  end
end
