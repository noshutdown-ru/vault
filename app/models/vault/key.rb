module Vault
  require 'csv'
  require 'iconv'

  class Vault::Key < ActiveRecord::Base
    include Redmine::SafeAttributes

    belongs_to :project
    has_and_belongs_to_many :tags, join_table: 'keys_vault_tags'

    safe_attributes 'project_id', 'name', 'body', 'login', 'type', 'file', 'url', 'comment', 'whitelist'

    def tags=(tags_string)
      tag_objects = Vault::Tag.create_from_string(tags_string)
      self.tags.clear
      self.tags << tag_objects
    end

    def encrypt!
      self
    end

    def decrypt!
      self
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
  end

  class Vault::KeysVaultTags < ActiveRecord::Base
  end
end
