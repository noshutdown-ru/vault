class CreateKeyAuditLogs < ActiveRecord::Migration[5.2]
  def up
    unless table_exists?(:key_audit_logs)
      create_table :key_audit_logs do |t|
        key_id_column = connection.columns(:keys).find { |column| column.name == 'id' }
        t.column :key_id, key_id_column.type, limit: key_id_column.limit, null: false, index: true
        t.integer :user_id, null: true, index: true
        t.string :action, null: false, index: true
        if legacy_mariadb_without_json?
          # MariaDB's JSON alias was introduced in 10.2.7. The model already
          # declares both attributes as :json, so LONGTEXT preserves the same
          # Ruby arrays/hashes on older servers without database JSON syntax.
          t.text :fields_changed, limit: 4_294_967_295, charset: 'utf8mb4', collation: 'utf8mb4_bin'
          t.text :data, limit: 4_294_967_295, charset: 'utf8mb4', collation: 'utf8mb4_bin'
        else
          t.json :fields_changed
          t.json :data
        end

        t.timestamps
      end

      add_foreign_key :key_audit_logs, :keys, column: :key_id, on_delete: :cascade if table_exists?(:keys)
      add_foreign_key :key_audit_logs, :users, column: :user_id, on_delete: :nullify if table_exists?(:users)
      add_index :key_audit_logs, [:key_id, :created_at], name: 'index_key_audit_logs_by_key_and_time'
    end
  end

  def legacy_mariadb_without_json?
    connection.respond_to?(:mariadb?) && connection.mariadb? &&
      connection.database_version < '10.2.7'
  end

  def down
    drop_table :key_audit_logs if table_exists?(:key_audit_logs)
  end
end
