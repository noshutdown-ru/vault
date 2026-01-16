class EncryptFilesJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "=========================================="
    Rails.logger.info "ENCRYPTING FILES - Started"
    Rails.logger.info "=========================================="

    total = 0
    encrypted = 0
    failed = 0
    skipped = 0

    Vault::Key.where.not(file: nil).where.not(file: '').each do |key|
      total += 1

      file_path = File.join(Vault::KEYFILES_DIR, key.file)

      unless File.exist?(file_path)
        Rails.logger.warn "  ⚠ SKIPPED: Key #{key.id} (#{key.name}) - File not found at #{file_path}"
        skipped += 1
        next
      end

      begin
        if key.encrypt_file!
          Rails.logger.info "  ✓ ENCRYPTED: Key #{key.id} (#{key.name})"
          encrypted += 1
        else
          Rails.logger.error "  ✗ FAILED: Key #{key.id} (#{key.name}) - encryption_returned_false"
          failed += 1
        end
      rescue => e
        Rails.logger.error "  ✗ FAILED: Key #{key.id} (#{key.name}) - #{e.message}"
        failed += 1
      end
    end

    Rails.logger.info "=========================================="
    Rails.logger.info "FILE ENCRYPTION SUMMARY"
    Rails.logger.info "=========================================="
    Rails.logger.info "Total files processed: #{total}"
    Rails.logger.info "Successfully encrypted: #{encrypted}"
    Rails.logger.info "Failed: #{failed}"
    Rails.logger.info "Skipped (not found): #{skipped}"
    Rails.logger.info "=========================================="

    if failed > 0
      Rails.logger.warn "⚠ WARNING: #{failed} files failed to encrypt"
    else
      Rails.logger.info "✓ All files encrypted successfully!"
    end
  end
end
