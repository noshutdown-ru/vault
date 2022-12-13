if Redmine::VERSION.to_s.start_with?('4')
  class AddWhitelistToKeys < ActiveRecord::Migration[4.2]
    def change
      add_column :keys, :whitelist, :string, default: ''
    end
  end
else
  class AddWhitelistToKeys < ActiveRecord::Migration[6.1]
    def change
      add_column :keys, :whitelist, :string, default: ''
    end
  end
end
