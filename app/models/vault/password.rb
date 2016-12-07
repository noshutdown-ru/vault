module Vault
  class Password < Key

    before_save :encrypt!
    after_save :decrypt!

    def encrypt!
      self.body = Encryptor::encrypt(self.body)
      self
    end

    def decrypt!
      self.body = Encryptor::decrypt(self.body)
      self
    end

  end
end
