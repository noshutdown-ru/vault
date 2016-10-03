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
      Vault::Key.all.each do |user|
        csv << user.attributes.values
      end
    end

    fname = "keys_#{DateTime.now.to_s}.csv"
    File.write("/tmp/#{fname}",@csv_string)

  end
end
