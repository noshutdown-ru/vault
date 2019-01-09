class AddOwnerToKeys < ActiveRecord::Migration[4.2]
  def change
    add_column :keys, :owner, :string
  end
end
