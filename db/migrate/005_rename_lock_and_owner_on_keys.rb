class RenameLockAndOwnerOnKeys < ActiveRecord::Migration[4.2]
  def change
    rename_column :keys, :lock, :name
    rename_column :keys, :owner, :login
  end
end
