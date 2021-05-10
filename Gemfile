source 'https://rubygems.org'

redmine_version_file = File.expand_path("../../../lib/redmine/version.rb",__FILE__)

if (!File.exists? redmine_version_file)
  redmine_version_file = File.expand_path("lib/redmine/version.rb");
end

version_file = IO.read(redmine_version_file)
redmine_version_minor = version_file.match(/MINOR =/).post_match.match(/\d/)[0].to_i
redmine_version_major = version_file.match(/MAJOR =/).post_match.match(/\d/)[0].to_i

if Gem::Version.new(redmine_version_major) >= Gem::Version.new('4')
  gem 'protected_attributes_continued', '1.4.0'
end

gem 'roo'
gem 'iconv'
gem 'rubyzip', '~> 2.3.0'
gem "rack", ">= 2.1.4"
gem "nokogiri", "~> 1.11.1"
gem 'zip-zip'

group :test, :development do
  gem 'byebug'
  gem 'capybara-screenshot'
end
