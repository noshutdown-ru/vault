module RedmineCipher
  include Redmine::Ciphering

  def self.encrypt_text(text)
    Redmine::Ciphering.encrypt_text(text)
  end

  def self.decrypt_text(text)
    Redmine::Ciphering.decrypt_text(text)
  end

  def self.cipher_key
    Redmine::Ciphering.cipher_key
  end

end
