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
    # Verify copy buttons are present for accessing hidden passwords
    assert page.has_css? 'a.copy-key', count: 3
    # Verify decrypted passwords are available in hidden inputs for copying
    assert page.has_css? '#copy_body_1[value="123456"]', visible: false
    assert page.has_css? '#copy_body_2[value="000000"]', visible: false
  end

  def test_create_new_key
    log_user('jsmith','jsmith')
    visit '/projects/1/keys/new'
    within 'form#new_vault_key' do
      fill_in 'Name', with: 'FreeBSD server console'
      fill_in 'Login', with: 'root'
      fill_in 'URL', with: 'ssh root@freebsd'
      fill_in 'Password', with: '123456'
      fill_in 'Tags', with: 'ssh'
      fill_in 'Comment', with: 'Very important'
      select  'Password', from: 'Type'
      click_button 'Save'
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

  def test_generate_password_button
    log_user('jsmith','jsmith')
    visit '/projects/1/keys/new'
    # Verify the Generate button is present
    assert page.has_button? 'Generate', id: 'generate_password_btn'
    # Verify password field is empty
    password_field = find('#vault_key_body')
    assert password_field.value.blank?
    # Execute the password generation function directly
    page.execute_script('generatePassword();')
    # Verify a password was generated (not empty)
    password_field = find('#vault_key_body')
    refute password_field.value.blank?, 'Password should be generated'
    # Verify generated password is 20 characters long
    assert_equal 20, password_field.value.length
  end

  def test_show_key
    log_user('jsmith','jsmith')
    visit '/projects/1/keys/1/edit'
    within 'form.edit_vault_key' do
      assert_equal 'server1', find_field('Name').value
      assert_equal 'root', find_field('Login').value
      assert_equal '123456', find_field('Password').value
      assert_equal 'Important', find_field('Comment').value
      assert_equal 'Vault::Password', find_field('Type').value
      assert_equal 'ssh', find_field('Tags').value
    end
  end

end
