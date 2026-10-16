class FixKeyAuditLogsColumnTypes < ActiveRecord::Migration[5.2]
  def up
    return unless table_exists?(:key_audit_logs) && table_exists?(:keys)
    parent = connection.columns(:keys).find { |column| column.name == 'id' }
    child = connection.columns(:key_audit_logs).find { |column| column.name == 'key_id' }
    return if parent.type == child.type && parent.limit == child.limit
    remove_foreign_key :key_audit_logs, column: :key_id if foreign_key_exists?(:key_audit_logs, column: :key_id)
    change_column :key_audit_logs, :key_id, parent.type, limit: parent.limit, null: false
    add_foreign_key :key_audit_logs, :keys, column: :key_id, on_delete: :cascade
  end

  def down
    # Matching the parent primary-key width is required in both directions.
  end
end
