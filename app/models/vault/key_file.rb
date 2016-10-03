module Vault
class KeyFile < Key
  attr_accessible :file
  before_update :update_file, if: :file_changed?
  before_destroy :delete_file

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
