require File.expand_path('../../test_helper', __FILE__)
require 'tmpdir'

class VaultRedmine7CompatibilityTest < ActiveSupport::TestCase
  fixtures :users, :projects

  def setup
    @previous = Setting.plugin_vault
    Setting.plugin_vault = {'encryption_key' => '0123456789abcdef', 'encrypt_files' => true}
  end

  def teardown
    Setting.plugin_vault = @previous
  end

  def test_audit_key_foreign_key_matches_existing_primary_key_width
    columns = ActiveRecord::Base.connection
    parent = columns.columns(:keys).find { |c| c.name == 'id' }
    child = columns.columns(:key_audit_logs).find { |c| c.name == 'key_id' }
    assert_equal parent.type, child.type
    assert_equal parent.limit, child.limit
  end

  def test_password_creation_is_encrypted_and_audited
    key = Vault::Password.create!(name: 'Synthetic secret', body: 'test-only-secret',
      project: Project.find(1), audit_user: User.find(1))
    cipher = key.reload.read_attribute(:body)
    assert_not_equal 'test-only-secret', cipher
    assert_equal 'test-only-secret', Encryptor.decrypt(cipher)
    assert_equal 1, key.audit_logs.where(action: 'create', user_id: 1).count
    assert_not key.audit_logs.first.data.to_json.include?('test-only-secret')
  end

  def test_audit_json_preserves_nested_unicode_arrays_and_large_data
    key = Vault::Password.create!(name: 'Audit payload', body: 'test-only-secret',
      project: Project.find(1), audit_user: User.find(1))
    fields = ['login', 'comment']
    payload = {'nested' => {'items' => [1, true, nil, '中文🔐']}, 'comment' => '审计' * 20_000}
    log = Vault::KeyAuditLog.create!(key: key, user: User.find(1), action: 'update',
      fields_changed: fields, data: payload)
    assert_equal fields, log.reload.fields_changed
    assert_equal payload, log.data
    assert_operator payload.to_json.bytesize, :>, 65_535
    assert_instance_of Array, log.fields_changed
    assert_instance_of Hash, log.data
  end

  def test_metadata_edit_does_not_encrypt_file_twice
    file_name = "vault-test-#{SecureRandom.uuid}"
    path = File.join(Vault::KEYFILES_DIR, file_name)
    payload = "\x00\xFFtest attachment\x00".b
    File.binwrite(path, payload)
    key = Vault::Key.create!(name: 'Test attachment', file: file_name, project: Project.find(1), audit_user: User.find(1))
    encrypted = File.binread(path)
    assert_not_equal payload, encrypted
    assert_equal payload, key.file_content.b
    key.update!(name: 'Edited label')
    assert_equal encrypted, File.binread(path)
    assert_equal payload, key.file_content.b
    assert key.audit_logs.where(action: 'update').exists?
  ensure
    File.delete(path) if path && File.exist?(path)
  end
end
