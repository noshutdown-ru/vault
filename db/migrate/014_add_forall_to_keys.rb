if Redmine::VERSION.to_s.start_with?('4')
  class AddForallToKeys < ActiveRecord::Migration[4.2]
    def change
      add_column :keys, :forall, :boolean, default: false
    end
  end
else
  class AddForallToKeys < ActiveRecord::Migration[6.1]
    def change
      add_column :keys, :forall, :boolean, default: false
    end
  end
end
