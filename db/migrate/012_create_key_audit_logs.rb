class CreateKeyAuditLogs < ActiveRecord::Migration[5.2]
  def change
    unless table_exists?(:key_audit_logs)
      create_table :key_audit_logs do |t|
        t.integer :key_id, null: false, index: true
        t.integer :user_id, null: true, index: true
        t.string :action, null: false, index: true  # create, update, delete, view, etc.
        t.json :fields_changed, default: []         # ["name", "login", "whitelist"]
        t.json :data, default: {}                   # extensible for future use: {old_value: "", new_value: "", ip: "", etc.}

        t.timestamps
      end

      # Foreign key constraints - only if keys table exists
      if table_exists?(:keys)
        add_foreign_key :key_audit_logs, :keys, column: :key_id
      end

      if table_exists?(:users)
        add_foreign_key :key_audit_logs, :users, column: :user_id
      end

      # Index for common queries
      add_index :key_audit_logs, [:key_id, :created_at], name: 'index_key_audit_logs_by_key_and_time'
    end
  end
end
