class DecryptFilesJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "=========================================="
    Rails.logger.info "DECRYPTING FILES - Started"
    Rails.logger.info "=========================================="

    total = 0
    decrypted = 0
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
        if key.decrypt_file!
          Rails.logger.info "  ✓ DECRYPTED: Key #{key.id} (#{key.name})"
          decrypted += 1
        else
          Rails.logger.error "  ✗ FAILED: Key #{key.id} (#{key.name}) - decryption_returned_false"
          failed += 1
        end
      rescue => e
        Rails.logger.error "  ✗ FAILED: Key #{key.id} (#{key.name}) - #{e.message}"
        failed += 1
      end
    end

    Rails.logger.info "=========================================="
    Rails.logger.info "FILE DECRYPTION SUMMARY"
    Rails.logger.info "=========================================="
    Rails.logger.info "Total files processed: #{total}"
    Rails.logger.info "Successfully decrypted: #{decrypted}"
    Rails.logger.info "Failed: #{failed}"
    Rails.logger.info "Skipped (not found): #{skipped}"
    Rails.logger.info "=========================================="

    if failed > 0
      Rails.logger.warn "⚠ WARNING: #{failed} files failed to decrypt"
    else
      Rails.logger.info "✓ All files decrypted successfully!"
    end
  end
end
