class RenameLockAndOwnerOnKeys < ActiveRecord::Migration[6.1]
  def change
    rename_column :keys, :lock, :name
    rename_column :keys, :owner, :login
  end
end
