if Redmine::VERSION.to_s.start_with?('4')
  class AddFileToKeys < ActiveRecord::Migration[4.2]
    def change
      add_column :keys, :file, :string
    end
  end
else
  class AddFileToKeys < ActiveRecord::Migration[6.1]
    def change
      add_column :keys, :file, :string
    end
  end
end
