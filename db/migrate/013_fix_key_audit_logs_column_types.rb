class FixKeyAuditLogsColumnTypes < ActiveRecord::Migration[5.2]
  def up
    return unless table_exists?(:key_audit_logs)

    # Migration 012 originally declared key_id as t.integer (4-byte).
    # keys.id is bigint (created via Migration[6.1] which defaults to bigint),
    # so MySQL/MariaDB rejects the foreign key due to type mismatch (errno: 150).
    # This migration corrects existing installations that ran 012 before the fix
    # (e.g. PostgreSQL, which is more lenient about FK type mismatches).
    #
    # user_id stays integer — Redmine's users.id is int(11) on all adapters.
    col = connection.columns(:key_audit_logs).find { |c| c.name == 'key_id' }
    if col&.type == :integer
      remove_foreign_key :key_audit_logs, column: :key_id if foreign_key_exists?(:key_audit_logs, column: :key_id)
      change_column :key_audit_logs, :key_id, :bigint, null: false
      add_foreign_key :key_audit_logs, :keys, column: :key_id, on_delete: :cascade if table_exists?(:keys)
    end
  end

  def down
    return unless table_exists?(:key_audit_logs)

    if column_exists?(:key_audit_logs, :key_id)
      remove_foreign_key :key_audit_logs, column: :key_id if foreign_key_exists?(:key_audit_logs, column: :key_id)
      change_column :key_audit_logs, :key_id, :integer, null: false
      add_foreign_key :key_audit_logs, :keys, column: :key_id, on_delete: :cascade if table_exists?(:keys)
    end
  end
end
