class AddOwnerToKeys < ActiveRecord::Migration[6.1]
  def change
    add_column :keys, :owner, :string
  end
end
