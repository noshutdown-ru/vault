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

        Vault::Key.create(
            project_id: rhash['project_id'],
            name: rhash['name'],
            login: rhash['login'],
            type: rhash['type'],
            body: decryptb,
            url: rhash['url'],
            comment: rhash['comment']
        )

      end

      def whitelisted?(user)
        return true if self.whitelist.blank? || user.admin
        whitelisted = self.whitelist.split(",").include?(user.id.to_s)
        whitelisted
      end
    end
  end
end
