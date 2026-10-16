require File.expand_path('../../test_helper', __FILE__)

class VaultRedmine7FlowTest < Redmine::IntegrationTest
  fixtures :users, :projects, :roles, :members, :member_roles

  def setup
    super
    Setting.rest_api_enabled = '1'
    Setting.plugin_vault = {'encryption_key' => '0123456789abcdef'}
    Project.find(1).enabled_module_names = ['keys']
    Role.find(1).add_permission! :view_keys
    Role.find(1).add_permission! :edit_keys
    Role.find(1).add_permission! :download_keys
    Role.find(1).add_permission! :manage_whitelist_keys
    @key = Vault::Password.create!(name: 'Synthetic UAT password', body: 'test-secret', project: Project.find(1), whitelist: '', audit_user: User.find(1))
  end

  def test_password_ui_crud_and_audit
    log_user('admin', 'admin')
    get '/projects/1/keys'
    assert_response :success
    get "/projects/1/keys/#{@key.id}/edit"
    assert_response :success
    assert_select 'input[value=?]', 'test-secret'
    put "/projects/1/keys/#{@key.id}", params: {vault_key: {name: 'Edited synthetic password', body: 'updated-secret', login: 'test-user', tags: ''}}
    assert_response :redirect
    assert_equal 'updated-secret', Encryptor.decrypt(@key.reload.read_attribute(:body))
    assert @key.audit_logs.where(action: 'update', user_id: 1).exists?
    delete "/projects/1/keys/#{@key.id}"
    assert_response :redirect
    assert_nil Vault::Key.find_by(id: @key.id)
  end

  def test_unprivileged_user_cannot_read_or_write
    Role.all.each do |role|
      role.remove_permission! :view_keys
      role.remove_permission! :edit_keys
      role.remove_permission! :manage_whitelist_keys
      role.remove_permission! :whitelist_keys
    end
    assert_not User.find(2).allowed_to?(:view_keys, Project.find(1))
    assert_not User.find(2).allowed_to?(:edit_keys, Project.find(1))
    log_user('jsmith', 'jsmith')
    get "/projects/1/keys/#{@key.id}/edit"
    assert_response :forbidden
    put "/projects/1/keys/#{@key.id}", params: {vault_key: {body: 'forbidden'}}
    assert_response :forbidden
    assert_equal 'test-secret', Encryptor.decrypt(@key.reload.read_attribute(:body))
  end

  def test_json_list_never_exposes_password
    log_user('admin', 'admin')
    get '/projects/1/keys.json', headers: {'X-Redmine-API-Key' => User.find(1).api_key}
    assert_response :success
    assert_not response.body.include?('test-secret')
    assert_not JSON.parse(response.body)['keys'].first.key?('body')
  end

  def test_settings_preserve_key_when_not_submitted_and_normalize_false
    log_user('admin', 'admin')
    post '/vault_settings/save', params: {settings: {encrypt_files: '0'}}
    assert_response :redirect
    assert_equal '0123456789abcdef', Setting.plugin_vault['encryption_key']
    assert_not Vault::Key.file_encryption_enabled?
  end

  def test_nonadmin_cannot_manage_settings
    log_user('jsmith', 'jsmith')
    post '/vault_settings/save', params: {settings: {encryption_key: '1111111111111111'}}
    assert_response :forbidden
    assert_equal '0123456789abcdef', Setting.plugin_vault['encryption_key']
  end
end
