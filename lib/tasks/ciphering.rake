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

      desc 'Update Vault::Key body from keys.csv inside backup zip (use BACKUP=/path/to/backup.zip)'
      task :update_body_from_backup => :environment do
        require 'csv'
        require 'zip'

        backup_path = ENV['BACKUP']
        raise 'Missing BACKUP param. Example: rake redmine:plugins:vault:update_body_from_backup BACKUP=/tmp/backup.zip' if backup_path.to_s.strip.empty?
        raise "Backup file not found: #{backup_path}" unless File.exist?(backup_path)

        updated = 0
        skipped = 0

        Zip::File.open(backup_path) do |zipfile|
          keys_csv = zipfile.find_entry('keys.csv')
          raise 'keys.csv not found in backup zip' unless keys_csv

          Tempfile.create(['keys', '.csv']) do |tempfile|
            keys_csv.extract(tempfile.path) { true }

            CSV.foreach(tempfile.path, headers: true) do |row|
              rhash = row.to_hash

              key = nil
              key = Vault::Key.where(id: rhash['id']).first if rhash['id'].present?
              key ||= Vault::Key.where(name: rhash['name']).first if rhash['name'].present?

              unless key
                skipped += 1
                next
              end

              key.update_column(:body, Encryptor.encrypt(rhash['body'].to_s))
              updated += 1
            end
          end
        end

        puts "Updated body for #{updated} keys. Skipped #{skipped} rows."
      end


    end
  end
end
