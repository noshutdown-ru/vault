if Redmine::VERSION.to_s.start_with?('4')
  class AddTypeToKeys < ActiveRecord::Migration[4.2]
    def change
      add_column :keys, :type, :string, default: 'Password'
    end
  end
else
  class AddTypeToKeys < ActiveRecord::Migration[6.1]
    def change
      add_column :keys, :type, :string, default: 'Password'
    end
  end
end
