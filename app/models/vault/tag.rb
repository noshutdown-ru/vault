module Vault
  class Tag < ActiveRecord::Base
    self.table_name = 'vault_tags'
    has_and_belongs_to_many :keys, join_table: 'keys_vault_tags'

    validates :name, presence: true, uniqueness: true
    validates :color, presence: true

    def self.create_from_string(string)
      return [] if string.blank? || !string.is_a?(String)

      words = string.downcase.split(/,\s*/).map(&:strip)
      tags = words.map do |word|
        find_or_create_by(name: word) do |tag|
          tag.color = default_color(word)
        end
      end
      tags
    end

    def self.tags_to_string(tags)
      return '' if tags.empty?
      return (tags.map { |t| t.name }).join(', ')
    end

    def self.cloud_for_project(pid)
      tags_with_score = Vault::Tag.joins(:keys).where(keys: { project_id: pid }).group('vault_tags.name').count
      (tags_with_score.sort_by { |tag, count| count }).map(&:first).reverse.take(20)
    end

    def self.tags_list(pid)
      tags_with_score = Vault::Tag.joins(:keys).where(
        keys: { project_id: pid }
      ).group('vault_tags.name').group('vault_tags.id').map(&:name) # OPTIMIZE_ME!
    end

    def self.get_color(tag_name)
      tag = find_by(name: tag_name)
      tag.color if tag
    end

    def self.default_color(tag_name)
      # Generate a unique color code based on the tag name
      hash = Digest::MD5.hexdigest(tag_name)
      "##{hash[0..5]}"
    end
  end
end
