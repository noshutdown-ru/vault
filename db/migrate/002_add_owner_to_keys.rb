if Redmine::VERSION.to_s.start_with?('4')
  class AddOwnerToKeys < ActiveRecord::Migration[4.2]
    def change
      add_column :keys, :owner, :string
    end
  end
else
  class AddOwnerToKeys < ActiveRecord::Migration[6.1]
    def change
      add_column :keys, :owner, :string
    end
  end
end
