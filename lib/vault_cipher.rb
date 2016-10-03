module VaultCipher

  def self.encrypt_text(text)
    if cipher_key.blank? || text.blank?
      text
    else
      cipher = OpenSSL::Cipher.new 'AES-128-ECB'
      cipher.encrypt
      cipher.key = cipher_key

      encrypted = cipher.update(text) + cipher.final
      return Base64.encode64(encrypted).encode('utf-8')
    end
  end

  def self.decrypt_text(text)
    if cipher_key.blank? || text.blank?
      text
    else
      cipher = OpenSSL::Cipher.new 'AES-128-ECB'
      cipher.decrypt
      cipher.key = cipher_key

      decrypted = cipher.update(Base64.decode64(text))
      decrypted << cipher.final
      return decrypted
    end
  end

  def self.cipher_key
    Setting.plugin_vault['encryption_key']
  end

end
