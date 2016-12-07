module Vault
class Tag < ActiveRecord::Base
  self.table_name = 'vault_tags'
  has_and_belongs_to_many :keys
  unloadable
  attr_accessible :name

  validates :name, presence: true, uniqueness: true

  def Tag::create_from_string(string)
    return [] if string.blank?

    words = string.downcase.split(/,\s*/).map(&:strip)
    Tag.create(words.map { |t| {name: t} })
    tags = Tag.all.reduce({}) { |tags, t| tags.merge({t.name => t}) }
    return words.map { |w| tags[w] }
  end

  def Tag::tags_to_string(tags)
    return '' if tags.empty?
    return (tags.map { |t| t.name }).join(', ')
  end

  def Tag::cloud_for_project(pid)
    tags_with_score = Vault::Tag.joins(:keys).where(keys: {project_id: pid}).group('vault_tags.name').count
    (tags_with_score.sort_by { |tag,count| count }).map(&:first).reverse.take(20)
  end

  def Tag::tags_list(pid)
    tags_with_score = Vault::Tag.joins(:keys).where(
        keys: {project_id: pid}
    ).group('vault_tags.name').group('vault_tags.id').map(&:name) #OPTIMIZE_ME!
  end

end
end
