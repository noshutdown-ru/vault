class AddUrlCommentToKeys < ActiveRecord::Migration[4.2]
  def change
    add_column :keys, :url, :string
    add_column :keys, :comment, :text
  end
end
