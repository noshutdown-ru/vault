require_dependency 'project'
require_dependency "#{Rails.root}/plugins/vault/lib/vault"

module ProjectPatch
  def self.included(base)
    base.class_eval do
      has_many :keys, class_name: Vault::Key
    end
  end
end

Project.send(:include, ProjectPatch)
