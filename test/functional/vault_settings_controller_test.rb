require File.expand_path('../../test_helper', __FILE__)

class VaultSettingsControllerTest < Vault::ControllerTest
  fixtures :projects, :users, :roles, :members, :member_roles

  def setup
    @request.session[:user_id] = 1  # Admin user
  end

  def test_index_encryption_disabled
    Setting.plugin_vault['encrypt_files'] = false
    get :index

    assert_response :success
    assert_equal false, assigns(:encryption_enabled)
  end

  def test_index_encryption_enabled
    Setting.plugin_vault['encrypt_files'] = true
    get :index

    assert_response :success
    assert_equal true, assigns(:encryption_enabled)
  end

  def test_save_enable_encryption
    Setting.plugin_vault['encrypt_files'] = false

    post :save, params: {
      settings: {
        encryption_key: Setting.plugin_vault['encryption_key'],
        use_redmine_encryption: false,
        encrypt_files: 'on'
      }
    }

    assert_redirected_to vault_settings_path
    assert Setting.plugin_vault['encrypt_files']
  end

  def test_save_disable_encryption
    Setting.plugin_vault['encrypt_files'] = true

    post :save, params: {
      settings: {
        encryption_key: Setting.plugin_vault['encryption_key'],
        use_redmine_encryption: false,
        encrypt_files: ''
      }
    }

    assert_redirected_to vault_settings_path
    assert_nil Setting.plugin_vault['encrypt_files']
  end

  def test_encryption_setting_persists_after_save
    Setting.plugin_vault['encrypt_files'] = false

    post :save, params: {
      settings: {
        encryption_key: Setting.plugin_vault['encryption_key'],
        use_redmine_encryption: false,
        encrypt_files: 'true'
      }
    }

    # Verify it was saved
    assert Setting.plugin_vault['encrypt_files']

    # Get the index and verify it's still enabled
    get :index
    assert_equal true, assigns(:encryption_enabled)
  end

  def test_encryption_disabled_shows_false
    Setting.plugin_vault['encrypt_files'] = nil
    get :index

    assert_response :success
    assert_nil assigns(:encryption_enabled)
  end
end
