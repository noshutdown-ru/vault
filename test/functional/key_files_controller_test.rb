require File.expand_path('../../test_helper', __FILE__)
require 'fileutils'
require 'byebug'

class KeyFilesControllerTest < Vault::ControllerTest
  fixtures :projects, :users, :roles, :members, :member_roles
  plugin_fixtures :keys, :vault_tags, :keys_vault_tags

  def setup
    Role.find(1).add_permission! :view_keys
    Role.find(1).add_permission! :edit_keys
    Role.find(1).add_permission! :download_keys
    Project.find(1).enabled_module_names = [:keys]
    Setting.plugin_vault['use_null_encryption'] = 'on'
    FileUtils.cp 'plugins/vault/test/fixtures/keyfile.txt', "#{Vault::KEYFILES_DIR}/server.key"
  end

  def test_download_keyfile
    @request.session[:user_id] = 2

    get :download, project_id: 1, id: 3

    assert_response :success
    assert_equal 'application/octet-stream', response.content_type
    assert_equal "This is file for tests\n", response.body
    assert_equal 'attachment; filename="ssh_access"', response.header["Content-Disposition"]
  end

end
