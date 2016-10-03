class AddOwnerToKeys < ActiveRecord::Migration
  def change
    add_column :keys, :owner, :string
  end
end
