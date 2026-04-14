module Vault
  class Tag < ActiveRecord::Base
    self.table_name = 'vault_tags'
    has_and_belongs_to_many :keys
    attr_accessible :name

    validates :name, presence: true, uniqueness: true

    def self.create_from_string(string)
      return [] if string.blank?

      words = string.downcase.split(/,\s*/).map(&:strip)
      Tag.create(words.map { |t| { name: t } })
      tags = Tag.all.index_by(&:name)
      words.map { |w| tags[w] }
    end

    def self.tags_to_string(tags)
      return '' if tags.empty?
      tags.map(&:name).join(', ')
    end

    def self.cloud_for_project(pid)
      tags_with_score = joins(:keys)
        .where(keys: { project_id: pid })
        .group('vault_tags.name')
        .count

      tags_with_score.sort_by { |tag, count| count }.map(&:first).reverse.take(20)
    end

    def self.tags_list(pid)
      joins(:keys)
        .where(keys: { project_id: pid })
        .distinct
        .pluck(:name)
    end
  end
end