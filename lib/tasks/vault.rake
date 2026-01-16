namespace :redmine do
  namespace :plugins do
    namespace :vault do
      desc "Encrypt all existing unencrypted files"
      task encrypt_files: :environment do
        puts "Starting file encryption..."

        total = 0
        encrypted = 0
        failed = 0
        skipped = 0

        Vault::Key.where(is_encrypted: false).where.not(file: nil).where.not(file: '').each do |key|
          total += 1

          file_path = File.join(Vault::KEYFILES_DIR, key.file)

          unless File.exist?(file_path)
            puts "  ⚠ SKIPPED: Key #{key.id} (#{key.name}) - File not found at #{file_path}"
            skipped += 1
            next
          end

          if key.encrypt_file!
            puts "  ✓ ENCRYPTED: Key #{key.id} (#{key.name})"
            encrypted += 1
          else
            puts "  ✗ FAILED: Key #{key.id} (#{key.name})"
            failed += 1
          end
        end

        puts "\n=========================================="
        puts "Encryption Summary"
        puts "=========================================="
        puts "Total files processed: #{total}"
        puts "Successfully encrypted: #{encrypted}"
        puts "Failed: #{failed}"
        puts "Skipped (not found): #{skipped}"
        puts "=========================================="

        if failed > 0
          puts "\n⚠ WARNING: #{failed} files failed to encrypt. Check logs for details."
          exit 1
        else
          puts "\n✓ All files encrypted successfully!"
        end
      end

      desc "Decrypt all encrypted files"
      task decrypt_files: :environment do
        puts "Starting file decryption..."

        total = 0
        decrypted = 0
        failed = 0
        skipped = 0

        Vault::Key.where(is_encrypted: true).where.not(file: nil).where.not(file: '').each do |key|
          total += 1

          file_path = File.join(Vault::KEYFILES_DIR, key.file)

          unless File.exist?(file_path)
            puts "  ⚠ SKIPPED: Key #{key.id} (#{key.name}) - File not found at #{file_path}"
            skipped += 1
            next
          end

          if key.decrypt_file!
            puts "  ✓ DECRYPTED: Key #{key.id} (#{key.name})"
            decrypted += 1
          else
            puts "  ✗ FAILED: Key #{key.id} (#{key.name})"
            failed += 1
          end
        end

        puts "\n=========================================="
        puts "Decryption Summary"
        puts "=========================================="
        puts "Total files processed: #{total}"
        puts "Successfully decrypted: #{decrypted}"
        puts "Failed: #{failed}"
        puts "Skipped (not found): #{skipped}"
        puts "=========================================="

        if failed > 0
          puts "\n⚠ WARNING: #{failed} files failed to decrypt. Check logs for details."
          exit 1
        else
          puts "\n✓ All files decrypted successfully!"
        end
      end

      desc "Show encryption status of all files"
      task encrypt_status: :environment do
        puts "\nFile Encryption Status Report"
        puts "=========================================="

        encrypted_count = Vault::Key.where(is_encrypted: true).where.not(file: nil).where.not(file: '').count
        unencrypted_count = Vault::Key.where(is_encrypted: false).where.not(file: nil).where.not(file: '').count
        total_with_files = encrypted_count + unencrypted_count

        puts "Total keys with files: #{total_with_files}"
        puts "  • Encrypted: #{encrypted_count}"
        puts "  • Unencrypted: #{unencrypted_count}"
        puts "  • Encryption enabled: #{Vault::Key.file_encryption_enabled?}"
        puts "\nRecent keys:"
        puts "=========================================="

        Vault::Key.where.not(file: nil).where.not(file: '').order(updated_at: :desc).limit(10).each do |key|
          status = key.is_encrypted? ? "🔐 ENCRYPTED" : "🔓 UNENCRYPTED"
          puts "#{status} | Key ##{key.id} | #{key.name}"
        end
      end
    end
  end
end
