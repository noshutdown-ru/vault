if Redmine::VERSION.to_s.start_with?('4')
  class RenameLockAndOwnerOnKeys < ActiveRecord::Migration[4.2]
    def change
      rename_column :keys, :lock, :name
      rename_column :keys, :owner, :login
    end
  end
else
  class RenameLockAndOwnerOnKeys < ActiveRecord::Migration[6.1]
    def change
      rename_column :keys, :lock, :name
      rename_column :keys, :owner, :login
    end
  end
end
