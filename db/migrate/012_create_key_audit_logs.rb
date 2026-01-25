class CreateKeyAuditLogs < ActiveRecord::Migration[5.2]
  def up
    unless table_exists?(:key_audit_logs)
      create_table :key_audit_logs do |t|
        t.integer :key_id, null: false, index: true
        t.integer :user_id, null: true, index: true
        t.string :action, null: false, index: true
        t.json :fields_changed, default: []
        t.json :data, default: {}

        t.timestamps
      end

      add_foreign_key :key_audit_logs, :keys, column: :key_id, on_delete: :cascade if table_exists?(:keys)
      add_foreign_key :key_audit_logs, :users, column: :user_id, on_delete: :nullify if table_exists?(:users)
      add_index :key_audit_logs, [:key_id, :created_at], name: 'index_key_audit_logs_by_key_and_time'
    end
  end

  def down
    drop_table :key_audit_logs if table_exists?(:key_audit_logs)
  end
end
