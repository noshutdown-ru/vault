# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../../test/ui/base')
require File.expand_path(File.dirname(__FILE__) + '/integration/steps')
require 'capybara-screenshot/minitest'

module Vault

  module PluginFixturesLoader
    def plugin_fixtures(*symbols)
      ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/', symbols)
    end
  end

  class UnitTest < ActiveSupport::TestCase
    extend PluginFixturesLoader
  end

  class ControllerTest < ActionController::TestCase
    extend PluginFixturesLoader
  end

  class IntegrationTest < ActionDispatch::IntegrationTest
    extend PluginFixturesLoader
    include Steps
    setup do
      Capybara.current_driver = :rack_test
    end
    teardown do
      Capybara.reset_sessions!
    end
  end

end
