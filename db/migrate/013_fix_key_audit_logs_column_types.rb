class FixKeyAuditLogsColumnTypes < ActiveRecord::Migration[5.2]
  def up
    return unless table_exists?(:key_audit_logs)

    # Migration 012 originally declared key_id/user_id as t.integer (4-byte).
    # MySQL/MariaDB requires foreign key columns to exactly match the referenced
    # primary key type (bigint). This migration corrects existing installations
    # that ran 012 before the fix (e.g. PostgreSQL, which is more lenient).
    if column_exists?(:key_audit_logs, :key_id) && column_for(:key_audit_logs, :key_id).sql_type.start_with?('int(', 'integer')
      remove_foreign_key :key_audit_logs, column: :key_id if foreign_key_exists?(:key_audit_logs, column: :key_id)
      change_column :key_audit_logs, :key_id, :bigint, null: false
      add_foreign_key :key_audit_logs, :keys, column: :key_id, on_delete: :cascade if table_exists?(:keys)
    end

    if column_exists?(:key_audit_logs, :user_id) && column_for(:key_audit_logs, :user_id).sql_type.start_with?('int(', 'integer')
      remove_foreign_key :key_audit_logs, column: :user_id if foreign_key_exists?(:key_audit_logs, column: :user_id)
      change_column :key_audit_logs, :user_id, :bigint, null: true
      add_foreign_key :key_audit_logs, :users, column: :user_id, on_delete: :nullify if table_exists?(:users)
    end
  end

  def down
    return unless table_exists?(:key_audit_logs)

    if column_exists?(:key_audit_logs, :key_id)
      remove_foreign_key :key_audit_logs, column: :key_id if foreign_key_exists?(:key_audit_logs, column: :key_id)
      change_column :key_audit_logs, :key_id, :integer, null: false
      add_foreign_key :key_audit_logs, :keys, column: :key_id, on_delete: :cascade if table_exists?(:keys)
    end

    if column_exists?(:key_audit_logs, :user_id)
      remove_foreign_key :key_audit_logs, column: :user_id if foreign_key_exists?(:key_audit_logs, column: :user_id)
      change_column :key_audit_logs, :user_id, :integer, null: true
      add_foreign_key :key_audit_logs, :users, column: :user_id, on_delete: :nullify if table_exists?(:users)
    end
  end
end
