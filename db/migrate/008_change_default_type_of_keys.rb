class ChangeDefaultTypeOfKeys < ActiveRecord::Migration
  def up
    change_column :keys, :type, :string, default: 'Vault::Password'

    execute <<-SQL
      UPDATE `keys`
      SET type="Vault::Password"
      WHERE type="Password"
    SQL
    execute <<-SQL
      UPDATE `keys`
      SET type="Vault::KeyFile"
      WHERE type="KeyFile"
    SQL
  end

  def down
    change_column :keys, :type, :string, default: 'Password'

    execute <<-SQL
      UPDATE `keys`
      SET type="Password"
      WHERE type="Vault::Password"
    SQL
    execute <<-SQL
      UPDATE `keys`
      SET type="KeyFile"
      WHERE type="Vault::KeyFile"
    SQL

  end

end
