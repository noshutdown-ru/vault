class AddTimestampsToKeys < ActiveRecord::Migration[5.2]
  def up
    if table_exists?(:keys)
      unless column_exists?(:keys, :created_at)
        add_column :keys, :created_at, :datetime
      end

      unless column_exists?(:keys, :updated_at)
        add_column :keys, :updated_at, :datetime
      end

      # Set default timestamps for existing records using ORM
      Key.where(created_at: nil).update_all(created_at: Time.current, updated_at: Time.current)
    end
  end

  def down
    if table_exists?(:keys)
      remove_column :keys, :created_at if column_exists?(:keys, :created_at)
      remove_column :keys, :updated_at if column_exists?(:keys, :updated_at)
    end
  end
end
