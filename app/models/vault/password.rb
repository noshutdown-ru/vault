module Vault
  class Password < Key

    before_save :encrypt!
    after_save :decrypt!

    def encrypt!
      self.body = Encryptor::encrypt(self.body)
      self
    end

    #TODO: all data should be stored in UTF-8
    def decrypt!
      decrypted = Encryptor::decrypt(self.body)
      self.body = decrypted ? decrypted.force_encoding('UTF-8') : nil
      self
    end

  end
end
