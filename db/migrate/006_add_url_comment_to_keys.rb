class AddUrlCommentToKeys < ActiveRecord::Migration[6.1]
  def change
    add_column :keys, :url, :string
    add_column :keys, :comment, :text
  end
end
