module Vault
  require 'csv'
  require 'iconv'

  class Vault::Key < ActiveRecord::Base
    include Redmine::SafeAttributes

    belongs_to :project
    has_and_belongs_to_many :tags, join_table: 'keys_vault_tags'
    has_many :audit_logs, class_name: 'Vault::KeyAuditLog', foreign_key: 'key_id', dependent: :destroy

    safe_attributes 'project_id', 'name', 'body', 'login', 'type', 'file', 'url', 'comment', 'whitelist'

    before_create :log_creation
    before_update :log_update
    before_destroy :log_deletion

    attr_accessor :audit_user

    # Encrypt newly uploaded files if encryption is enabled
    after_save :encrypt_file_if_needed

    def tags=(tags_string)
      tag_objects = Vault::Tag.create_from_string(tags_string)
      self.tags.clear
      self.tags << tag_objects
    end

    # Encrypt file on disk
    def encrypt_file!
      return false unless file.present?

      file_path = File.join(Vault::KEYFILES_DIR, file)
      return false unless File.exist?(file_path)

      begin
        # Read file content
        file_content = File.binread(file_path)

        # Encrypt content
        encrypted_content = Encryptor.encrypt(file_content)

        # Write encrypted content back
        File.binwrite(file_path, encrypted_content)
        true
      rescue => e
        Rails.logger.error("File encryption failed for key #{id}: #{e.message}")
        false
      end
    end

    # Decrypt file on disk
    def decrypt_file!
      return false unless file.present?

      file_path = File.join(Vault::KEYFILES_DIR, file)
      return false unless File.exist?(file_path)

      begin
        # Read file content
        file_content = File.binread(file_path)

        # Decrypt content
        decrypted_content = Encryptor.decrypt(file_content)

        # Write decrypted content back
        File.binwrite(file_path, decrypted_content)
        true
      rescue => e
        Rails.logger.error("File decryption failed for key #{id}: #{e.message}")
        false
      end
    end

    # Get file content (automatically decrypts if encryption enabled)
    def file_content
      return nil unless file.present?

      file_path = File.join(Vault::KEYFILES_DIR, file)
      return nil unless File.exist?(file_path)

      begin
        content = File.binread(file_path)

        # If encryption is enabled, try to decrypt
        if self.class.file_encryption_enabled?
          begin
            Encryptor.decrypt(content)
          rescue => e
            # If decryption fails, file might not be encrypted yet, return raw content
            Rails.logger.warn("Decryption failed for key #{id}, returning raw content: #{e.message}")
            content
          end
        else
          content
        end
      rescue => e
        Rails.logger.error("Failed to read file content for key #{id}: #{e.message}")
        nil
      end
    end

    # Save file content (unencrypted; encryption handled by background jobs)
    def save_file_content(file_data)
      return false unless file.present?

      file_path = File.join(Vault::KEYFILES_DIR, file)

      begin
        # Write unencrypted content to disk
        File.binwrite(file_path, file_data)
        true
      rescue => e
        Rails.logger.error("Failed to save file content for key #{id}: #{e.message}")
        false
      end
    end

    # Check if file encryption is enabled
    def self.file_encryption_enabled?
      Setting.plugin_vault['encrypt_files']
    end

    def whitelisted?(user, project)
      return true if user.admin || (!user.allowed_to?(:whitelist_keys, project) && user.allowed_to?(:view_project, project))

      whitelist_ids = self.whitelist.split(',')
      return true if whitelist_ids.include?(user.id.to_s)

      whitelist_ids.each do |id|
        return true if User.in_group(id).where(id: user.id).any?
      end

      false
    end

    def as_json(options = {})
      super(options).except('body', 'file')
    end

    private

    # Automatically encrypt newly uploaded files if encryption is enabled
    def encrypt_file_if_needed
      return unless file.present?
      return unless self.class.file_encryption_enabled?

      encrypt_file!
    end

    def self.import(file)
      CSV.foreach(file.path, headers: true) do |row|
        rhash = row.to_hash

        decryptb = Encryptor::decrypt(rhash['body'])

        key = Vault::Key.where("name = ?", rhash['name']).first

        unless key
          begin
            Vault::Key.create(
              project_id: rhash['project_id'],
              name: rhash['name'],
              body: decryptb,
              login: rhash['login'],
              type: rhash['type'],
              file: rhash['file'],
              url: rhash['url'],
              comment: rhash['comment'],
              whitelist: rhash['comment']
            ).update_column(:id, rhash['id'])
          rescue
          end
        else
          begin
            Vault::Key.update(
              key.id,
              project_id: rhash['project_id'],
              name: rhash['name'],
              body: decryptb,
              login: rhash['login'],
              type: rhash['type'],
              file: rhash['file'],
              url: rhash['url'],
              comment: rhash['comment'],
              whitelist: rhash['comment']
            )
          rescue

          end
        end
      end
    end

    def log_creation
      Vault::KeyAuditLog.log_action(self, 'create', audit_user)
    end

    def log_update
      changed_fields = changed.select { |field| %w[name body login url comment whitelist].include?(field) }
      if changed_fields.any?
        Vault::KeyAuditLog.log_action(self, 'update', audit_user, changed_fields)
      end
    end

    def log_deletion
      Vault::KeyAuditLog.log_action(self, 'delete', audit_user)
    end
  end

  class Vault::KeysVaultTags < ActiveRecord::Base
  end
end
