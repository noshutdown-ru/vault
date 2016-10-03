class AddUrlCommentToKeys < ActiveRecord::Migration
  def change
    add_column :keys, :url, :string
    add_column :keys, :comment, :text
  end
end
