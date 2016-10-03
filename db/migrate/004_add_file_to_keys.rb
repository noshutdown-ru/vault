class AddFileToKeys < ActiveRecord::Migration
  def change
    add_column :keys, :file, :string
  end
end
