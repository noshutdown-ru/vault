class RenameLockAndOwnerOnKeys < ActiveRecord::Migration
  def change
    rename_column :keys, :lock, :name
    rename_column :keys, :owner, :login
  end
end
