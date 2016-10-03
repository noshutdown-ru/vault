namespace :redmine do
  namespace :plugins do
    namespace :vault do

      desc 'Encrypts encryptable fields in the database'
      task :encrypt => :environment do
        unless Encryptor.encrypt_all(Vault::Password,:body) #ugly as hell!
          raise "Some objects could not be saved after encryption, update was rolled back"
        end
      end

      desc 'Decrypts encryptable fields in the database'
      task :decrypt => :environment do
        unless Encryptor.decrypt_all(Vault::Password,:body) #ugly
          raise "Some objects could not be saved after decryption, update was rolled back"
        end
      end

      desc 'Convert to current settings encryptable fields in the database'
      task :convert => :environment do
        code = if Setting.plugin_vault['use_redmine_encryption']
          Encryptor.decrypt_all(Vault::Password,:body, engine: VaultCipher) &&
            Encryptor.encrypt_all(Vault::Password,:body, engine: RedmineCipher)
        else 
          Encryptor.decrypt_all(Vault::Password,:body, engine: RedmineCipher) &&
            Encryptor.encrypt_all(Vault::Password,:body, engine: VaultCipher)
        end
        raise "Some objects could not be saved after decryption, update was rolled back" unless code
      end
      #todo: remove this code fore Backup module
      desc 'Create backup keys'
      task :backup => :environment do
        unless Encryptor.backup #ugly as hell!
          raise "File does not save"
        end
      end

    end
  end
end
