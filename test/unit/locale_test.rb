require File.expand_path('../../test_helper', __FILE__)
require 'yaml'

class LocaleTest < ActiveSupport::TestCase

  LOCALES_DIR = File.expand_path('../../../config/locales', __FILE__)
  REFERENCE_LOCALE = 'en'

  def self.flatten_keys(hash, prefix = '')
    hash.each_with_object([]) do |(k, v), keys|
      full_key = prefix.empty? ? k.to_s : "#{prefix}.#{k}"
      if v.is_a?(Hash)
        keys.concat(flatten_keys(v, full_key))
      else
        keys << full_key
      end
    end
  end

  def reference_keys
    @reference_keys ||= begin
      data = YAML.load_file(File.join(LOCALES_DIR, "#{REFERENCE_LOCALE}.yml"))
      self.class.flatten_keys(data[REFERENCE_LOCALE])
    end
  end

  def locale_files
    Dir.glob(File.join(LOCALES_DIR, '*.yml')).reject do |f|
      File.basename(f, '.yml') == REFERENCE_LOCALE
    end
  end

  def test_all_locales_have_reference_keys
    missing = {}

    locale_files.each do |file|
      locale = File.basename(file, '.yml')
      data = YAML.load_file(file)
      locale_keys = self.class.flatten_keys(data[locale] || {})
      absent = reference_keys - locale_keys
      missing[locale] = absent unless absent.empty?
    end

    assert missing.empty?,
      "Locale(s) missing keys from #{REFERENCE_LOCALE}.yml:\n" +
      missing.map { |locale, keys| "  #{locale}: #{keys.join(', ')}" }.join("\n")
  end

end
