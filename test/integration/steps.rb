require 'capybara/rails'

module Vault

  module Steps
    include Capybara::DSL

		def log_user(login, password)
			visit '/my/page'
			assert_equal '/login', current_path
			within('#login-form form') do
				fill_in 'username', :with => login
				fill_in 'password', :with => password
				find('input[name=login]').click
			end
			assert_equal '/my/page', current_path
		end
  end

end
