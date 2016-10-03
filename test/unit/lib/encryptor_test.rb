require File.expand_path('../../../test_helper', __FILE__)

class EncryptorTest < ActiveSupport::TestCase

  def setup
    Setting.plugin_vault = {}
  end

  def test_encryptor_engine_null
    Setting.plugin_vault['use_null_encryption'] = 'on'
    assert_equal NullCipher, Encryptor.engine 
  end

  def test_encryptor_engine_redmine
    Setting.plugin_vault['use_redmine_encryption'] = 'on'
    Setting.plugin_vault['use_null_encryption'] = 'on'
    assert_equal NullCipher, Encryptor.engine 
  end

  def test_encryptor_engine_default
    assert_equal VaultCipher, Encryptor.engine 
  end

end
