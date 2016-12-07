class ChangeDefaultTypeOfKeys < ActiveRecord::Migration
  def up
    change_column :keys, :type, :string, default: 'Vault::Password'

    Vault::Key.where(type: "Password").update_all(type: 'Vault::Password')
    Vault::Key.where(type: "KeyFile").update_all(type: 'Vault::KeyFile')
  end

  def down
    change_column :keys, :type, :string, default: 'Password'

    Vault::Key.where(type: "Vault::Password").update_all(type: 'Password')
    Vault::Key.where(type: "Vault::KeyFile").update_all(type: 'KeyFile')
  end

end
