require File.expand_path('../../test_helper', __FILE__)

require 'byebug'

Capybara.default_driver = :rack_test

class KeysTest < Vault::IntegrationTest

  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles
  plugin_fixtures :keys,
                  :vault_tags,
                  :keys_vault_tags

  def setup
    Role.find(1).add_permission! :view_keys
    Role.find(1).add_permission! :edit_keys
    Project.find(1).enabled_module_names = [:keys]
   #Setting.plugin_vault['use_null_encryption'] = 'on'
    Setting.plugin_vault['encryption_key'] = 'AilkyiakillEctIb'
    Encryptor.encrypt_all(Vault::Password,:body)
  end

  def test_index
    log_user('jsmith','jsmith')
    visit '/projects/1/keys'
    assert page.has_css? 'table#keys_table'
    # Check that the hidden password input exists with the decrypted password value
    assert page.has_css? '#copy_body_1[value="123456"]', visible: false
    within_table 'keys_table' do
      assert_equal 3, all('tr').count
      assert has_content? 'server1'
      assert has_content? 'root@server1'
      assert has_content? 'root'
    end

    # Verify passwords are hidden (not displayed as plain text in visible content)
    assert page.has_no_content? '123456'
    # Verify decrypted password is available in hidden input for copying (for secure copy functionality)
    assert page.has_css? '#copy_body_1', visible: false
  end

  def test_create_new_key
    log_user('jsmith','jsmith')
    visit '/projects/1/keys/new'
    within 'form[id^="new_vault_key"]' do
      fill_in 'vault_key_name', with: 'FreeBSD server console'
      fill_in 'vault_key_login', with: 'root'
      fill_in 'vault_key_url', with: 'ssh root@freebsd'
      fill_in 'vault_key_body', with: '123456'
      fill_in 'vault_key_tags', with: 'ssh'
      fill_in 'vault_key_comment', with: 'Very important'
      select 'Password', from: 'vault_key_type'
      click_button 'Create'
    end
    assert page.has_content? 'Password was successfully created'
    key = Vault::Key.find_by_name('FreeBSD server console')
    refute_nil key
    key.decrypt!
    assert_equal 'root', key.login
    assert_equal 'ssh root@freebsd', key.url
    assert_equal '123456', key.body
    assert_equal 'ssh', key.tags[0].name
    assert_equal 'Very important', key.comment
    assert_equal 'Vault::Password', key.type
  end

  def test_show_key
    log_user('jsmith','jsmith')
    visit '/projects/1/keys/1/edit'
    within 'form[id^="edit_vault_key"]' do
      assert_equal 'server1', find_field('vault_key_name').value
      assert_equal 'root', find_field('vault_key_login').value
      assert_equal '123456', find_field('vault_key_body').value
      assert_equal 'Important', find_field('vault_key_comment').value
      assert_equal 'Vault::Password', find_field('vault_key_type').value
      assert_equal 'ssh', find_field('vault_key_tags').value
    end
  end

end
