class AddFileToKeys < ActiveRecord::Migration[6.1]
  def change
    add_column :keys, :file, :string
  end
end
