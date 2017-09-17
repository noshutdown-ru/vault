require File.expand_path('../../test_helper', __FILE__)

require 'byebug'

Capybara.default_driver = :rack_test

class KeyfileTest < Vault::IntegrationTest

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
    Setting.plugin_vault['use_null_encryption'] = 'on'
  end

  def test_index
    log_user('jsmith','jsmith')
    visit '/projects/1/keys'
    assert page.has_css? 'table#keys_table'
    within_table 'keys_table' do
      assert has_content? 'ssh_access'
      assert has_content? 'jsmith@server2'
      assert has_content? 'jsmith'
      assert has_link? 'keyfile_dl_3'
    end
  end

  #def test_create_new_key
  #  log_user('jsmith','jsmith')
  #  visit '/projects/1/keys/new'
  #  within 'form#new_vault_key' do
  #    fill_in 'Name', with: 'FreeBSD server console'
  #    fill_in 'Login', with: 'root'
  #    fill_in 'URL', with: 'ssh root@freebsd'
  #    fill_in 'Key', with: '123456'
  #    fill_in 'Tags', with: 'ssh'
  #    fill_in 'Comment', with: 'Very important'
  #    select  'Password', from: 'Type'
  #    click_button 'Save'
  #  end
  #  assert page.has_content? 'Key was successfully created'
  #  key = Vault::Key.find_by_name('FreeBSD server console')
  #  refute_nil key
  #  assert_equal 'root', key.login
  #  assert_equal 'ssh root@freebsd', key.url
  #  assert_equal '123456', key.body
  #  assert_equal 'ssh', key.tags[0].name
  #  assert_equal 'Very important', key.comment
  #  assert_equal 'Vault::Password', key.type
  #end

  #def test_show_key
  #  log_user('jsmith','jsmith')
  #  visit '/projects/1/keys/1/edit'
  #  within 'form.edit_vault_key' do
  #    assert_equal 'server1', find_field('Name').value
  #    assert_equal 'root', find_field('Login').value
  #    assert_equal '123456', find_field('Key').value
  #    assert_equal 'Important', find_field('Comment').value
  #    assert_equal 'Vault::Password', find_field('Type').value
  #    assert_equal 'ssh', find_field('Tags').value
  #  end
  #end

end
