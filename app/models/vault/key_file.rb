module Vault
  class KeyFile < Key
    before_save :encrypt!
    after_save :decrypt!
    before_update :update_file, if: :file_changed?
    before_destroy :delete_file

    def encrypt!
      self.body = Encryptor::encrypt(self.body)
      self
    end

    def decrypt!
      self.body = Encryptor::decrypt(self.body).force_encoding('UTF-8')
      self
    end

    private

    def update_file
      file = "#{Vault::KEYFILES_DIR}/#{file_was}"
      unless file_was.blank?
        File.delete(file) if File.exist?(file)
      end
    end

    def delete_file
      file = "#{Vault::KEYFILES_DIR}/#{self.file}"
      unless self.file.blank?
        File.delete(file) if File.exist?(file)
      end
    end
  end
end
