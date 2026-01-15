class AddTimestampsToKeys < ActiveRecord::Migration[5.2]
  def change
    if table_exists?(:keys)
      unless column_exists?(:keys, :created_at)
        add_column :keys, :created_at, :datetime
      end

      unless column_exists?(:keys, :updated_at)
        add_column :keys, :updated_at, :datetime
      end

      # Set default timestamps for existing records
      reversible do |dir|
        dir.up do
          execute("UPDATE keys SET created_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP WHERE created_at IS NULL")
        end
      end
    end
  end
end
