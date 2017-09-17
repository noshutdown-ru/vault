require File.expand_path('../../test_helper', __FILE__)
require 'fileutils'
require 'set'
require 'byebug'

class KeysControllerTest < Vault::ControllerTest
  fixtures :projects, :users, :roles, :members, :member_roles
  plugin_fixtures :keys, :vault_tags, :keys_vault_tags

  def setup
    Role.find(1).add_permission! :view_keys
    Role.find(1).add_permission! :edit_keys
    Project.find(1).enabled_module_names = [:keys]
    Setting.plugin_vault['use_null_encryption'] = 'on'
  end

  def test_index
    @request.session[:user_id] = 2
    get :index, project_id: 1

    assert_not_nil assigns(:keys)
    assert_response :success
    assert_template 'index'
  end

  def test_index_search
    @request.session[:user_id] = 2

    get :index, project_id: 1, query: '1', search_fild: 'name'

    assert_not_nil assigns(:keys)
    assert_equal 1, assigns(:keys).length
    assert_equal 'server1', assigns(:keys)[0].name
    assert_response :success
    assert_template 'index'
  end

  def test_new
    @request.session[:user_id] = 2
    get :new, project_id: 1

    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:key)
  end

  def test_unpriv_index
    @request.session[:user_id] = 3
    get :index, project_id: 1

    assert_response 403
  end

  def test_unpriv_create
    @request.session[:user_id] = 3
    post :create, project_id: 1, key: { name: 'root', body: '123456' } 

    assert_response 403
    refute Vault::Key.exists?(name: 'root')
  end

  def test_unpriv_new
    @request.session[:user_id] = 3
    get :new, project_id: 1

    assert_response 403
  end

  def test_edit
    @request.session[:user_id] = 2
    get :edit, project_id: 1, id: 1

    assert_response :success
    assert_template 'edit'
  end

  def test_delete
    @request.session[:user_id] = 2
    FileUtils.cp 'plugins/vault/test/fixtures/keyfile.txt', "#{Vault::KEYFILES_DIR}/server.key"

    delete :destroy, project_id: 1, id: 3

    assert_response :redirect
    assert_redirected_to '/projects/ecookbook/keys'

    key = Vault::Key.find_by_name('ssh_access')
    assert_nil key
    refute File.exists?("#{Vault::KEYFILES_DIR}/server.key")
  end

  def test_unpriv_edit
    @request.session[:user_id] = 3
    get :edit, project_id: 1, id: 1

    assert_response 403
  end

  def test_crossproject_edit
    @request.session[:user_id] = 2
    get :edit, project_id: 1, id: 2

    assert_response :redirect
  end

  def test_update_with_new_file
    @request.session[:user_id] = 2
    FileUtils.cp 'plugins/vault/test/fixtures/keyfile.txt', "#{Vault::KEYFILES_DIR}/server.key"

    put :update, id: 3, project_id: 1, vault_key: {file: fixture_file_upload('../../plugins/vault/test/fixtures/keyfile.txt')} 

    assert_response :redirect
    assert_redirected_to '/projects/ecookbook/keys'

    key = Vault::Key.find_by_name('ssh_access')
    refute_nil key
    refute File.exists?("#{Vault::KEYFILES_DIR}/server.key")
  end

  def test_update
    @request.session[:user_id] = 2
    put :update, id: 1, project_id: 1, vault_key: { name: 'database', login: 'me', type: 'Vault::KeyFile' }

    assert_response :redirect
    assert_redirected_to '/projects/ecookbook/keys'

    key = Vault::Key.find_by_name('database')
    refute_nil key
    assert_equal 'database', key.name
    assert_equal 'me', key.login
    assert_equal 'Vault::KeyFile', key.type
    assert_equal Project.find(1), key.project
    refute Vault::Key.find_by_name('server1')
  end

  def test_unpriv_update
    @request.session[:user_id] = 3
    put :update, id: 1, project_id: 1, vault_key: { name: 'database', body: '123456', login: 'me' }
    assert_response 403
  end

  def test_crossproject_update
    @request.session[:user_id] = 2
    put :update, id: 2, project_id: 1, vault_key: { name: 'database', body: '123456', login: 'me' }
    assert_response :redirect
  end

  def test_show
    @request.session[:user_id] = 2
    get :show, project_id: 1, id: 1

    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:key)
  end

  def test_crossproject_show
    @request.session[:user_id] = 2
    get :show, project_id: 1, id: 2
    assert_response :redirect
  end

  def test_unpriv_show
    @request.session[:user_id] = 3
    get :show, project_id: 1, id: 1
    assert_response 403
  end

  def test_create
    @request.session[:user_id] = 2
    post :create, project_id: 1, vault_key: { name: 'database', type: 'Vault::Password', login: 'me', body: 123456 } 

    assert_response :redirect
    assert_redirected_to '/projects/ecookbook/keys'

    key = Vault::Password.find_by_name('database')
    key.decrypt!
    assert_equal 'database', key.name
    assert_equal 'me', key.login
    assert_equal '123456', key.body
    assert_equal 'Vault::Password', key.type
    assert_equal Project.find(1), key.project
  end

  def test_create_with_tags
    @request.session[:user_id] = 2
    post :create, project_id: 1, vault_key: { name: 'router', type: 'Vault::Password', tags: "ssh, cisco" } 

    assert_response :redirect
    assert_redirected_to '/projects/ecookbook/keys'

    key = Vault::Password.find_by_name('router')
    key.decrypt!
    assert_equal 2, key.tags.count
    assert_equal ["ssh","cisco"], key.tags.map(&:name)
    assert_equal 'Vault::Password', key.type
  end

  def test_update_tags
    @request.session[:user_id] = 2
    put :update, id: 1, project_id: 1, vault_key: { tags: "mysql" }

    assert_response :redirect
    assert_redirected_to '/projects/ecookbook/keys'

    key = Vault::Key.find_by_name('server1')
    refute_nil key
    assert_equal 1, key.tags.count
    assert_equal ["mysql"], key.tags.map(&:name)
  end

  def test_tag_search
    @request.session[:user_id] = 2
    get :index, project_id: 1, query: "#ftp"

    assert_response :success
    assert_template 'index'

    keys = assigns(:keys)
    assert_not_nil keys
    assert_equal 1, keys.count 
    assert_equal Set.new(['ftp', 'ssh']), Set.new(keys[0].tags.map(&:name))
  end

  def test_upload_keyfile
    @request.session[:user_id] = 2

    post :create, project_id: 1, vault_key: { name: 'database', type: 'Vault::KeyFile', file: fixture_file_upload('../../plugins/vault/test/fixtures/keyfile.txt') } 

    assert_response :redirect
    assert_redirected_to '/projects/ecookbook/keys'

    key = Vault::Key.find_by_name('database')
    key.decrypt!
    assert_equal 'Vault::KeyFile', key.type
    assert File.exists?("#{Vault::KEYFILES_DIR}/#{key.file}"), "File: #{key.file} should be at Rails root keyfiles dir"
  end

end
