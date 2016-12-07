module Vault
  require 'csv'
  require 'iconv'

  class Vault::Key < ActiveRecord::Base
    belongs_to :project
    has_and_belongs_to_many :tags
    unloadable

    attr_accessible :project_id, :name, :body, :login, :type, :file, :project, :url, :comment, :whitelist

    #def tags=(tags_string)
    #  @tags = Vault::Tag.create_from_string(tags_string)
    #end

    def encrypt!
      self
    end

    def decrypt!
      self
    end

    def self.import(file)
      CSV.foreach(file.path, headers:true) do |row|
        rhash = row.to_hash

        decryptb = Encryptor::decrypt(rhash['body'])
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
      end
    end

    def whitelisted?(user,project)
      return true if user.current.admin or !user.current.allowed_to?(:whitelist_keys, project)
      return self.whitelist.split(",").include?(user.current.id.to_s)
    end

  end

  class Vault::KeysVaultTags < ActiveRecord::Base
  end

end
