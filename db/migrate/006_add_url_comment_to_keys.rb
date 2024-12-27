if Redmine::VERSION.to_s.start_with?('4')
  class AddUrlCommentToKeys < ActiveRecord::Migration[4.2]
    def change
      add_column :keys, :url, :string
      add_column :keys, :comment, :text
    end
  end
else
  class AddUrlCommentToKeys < ActiveRecord::Migration[6.1]
    def change
      add_column :keys, :url, :string
      add_column :keys, :comment, :text
    end
  end
end
