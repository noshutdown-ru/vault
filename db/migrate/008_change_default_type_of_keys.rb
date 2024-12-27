if Redmine::VERSION.to_s.start_with?('4')
  class ChangeDefaultTypeOfKeys < ActiveRecord::Migration[4.2]
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
else
  class ChangeDefaultTypeOfKeys < ActiveRecord::Migration[6.1]
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
end
