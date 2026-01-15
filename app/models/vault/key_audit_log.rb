module Vault
  class KeyAuditLog < ActiveRecord::Base
    self.table_name = 'key_audit_logs'

    belongs_to :key, class_name: 'Vault::Key', foreign_key: 'key_id'
    belongs_to :user, optional: true

    validates :key_id, :action, presence: true

    ACTIONS = %w[create update delete view].freeze

    scope :recent, -> { order(created_at: :desc) }
    scope :by_action, ->(action) { where(action: action) }
    scope :by_user, ->(user) { where(user_id: user.id) }

    def self.log_action(key, action, user = nil, fields_changed = [], data = {})
      create(
        key: key,
        user: user,
        action: action,
        fields_changed: fields_changed,
        data: data
      )
    end

    def user_name
      user&.login || 'System'
    end

    def readable_action
      action.capitalize
    end
  end
end
