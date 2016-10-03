require File.expand_path('../../test_helper', __FILE__)

class TagTest < Vault::UnitTest
  fixtures :projects
  plugin_fixtures :keys, :vault_tags, :keys_vault_tags

  def test_cloud
    cloud = Vault::Tag.cloud_for_project(1)
    assert_equal ['ssh','ftp'], cloud
  end

  def test_create_from_string
    
  end

end
