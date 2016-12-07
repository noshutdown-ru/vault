module Encryptor
  require 'csv'

  def self.encrypt(text, options={})
    e = options[:engine] || engine
    e.encrypt_text(text)
  end

  def self.decrypt(text, options={})
    e = options[:engine] || engine
    e.decrypt_text(text)
  end

  def self.engine
    s = Setting.plugin_vault
    return NullCipher if s['use_null_encryption']
    return RedmineCipher if s['use_redmine_encryption'] 
    return VaultCipher
  end

  def self.encrypt_all(model, attr, options={} )
    model.transaction do
      model.all.each do |p|
        p.update_column(attr, encrypt(p.read_attribute(attr), options))
      end
    end ? true : false
  end

  def self.decrypt_all(model, attr, options={})
    model.transaction do
      model.all.each do |p|
        p.update_column(attr, decrypt(p.read_attribute(attr), options))
      end
    end ? true : false
  end

  def self.backup

    @csv_string = CSV.generate do |csv|
      csv << Vault::Key.attribute_names
      Vault::Key.all.each do |key|
        csv << key.attributes.values
      end
    end

    @csv_tag_string = CSV.generate do |csv|
      csv << Vault::Tag.attribute_names
      Vault::Tag.all.each do |tag|
        csv << tag.attributes.values
      end
    end

    @csv_tag_keys_string = CSV.generate do |csv|
      csv << Vault::KeysVaultTags.attribute_names
      Vault::KeysVaultTags.all.each do |tag|
        csv << tag.attributes.values
      end
    end

    fname = "/tmp/backup-#{DateTime.now.to_s}.zip"

    Zip::File.open(fname, Zip::File::CREATE) do |zip_file|
      zip_file.file.open('keys.csv', 'w') { |f1| f1 << @csv_string }
      zip_file.file.open('tags.csv', 'w') { |f2| f2 << @csv_tag_string }
      zip_file.file.open('keys_tags.csv', 'w') { |f3| f3 << @csv_tag_keys_string }
    end

  end
end
