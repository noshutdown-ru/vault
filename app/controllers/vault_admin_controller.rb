class VaultAdminController < ApplicationController
  before_action :require_admin

  helper :sort
  include SortHelper

  def permissions_audit
    @audit_type = params[:type] || 'user'
    @users = User.active.order(:name)
    @keys = Vault::Key.includes(:project).order('keys.name')

    case @audit_type
    when 'user'
      if params[:user_id].present?
        @selected_user = User.find(params[:user_id])
        @accessible_keys = determine_accessible_keys(@selected_user)
        @key_reasons = categorize_access_reasons(@selected_user, @accessible_keys)
        @access_reasons = group_by_access_type(@key_reasons)
      end
    when 'key'
      if params[:key_id].present?
        @selected_key = Vault::Key.find(params[:key_id])
        @accessible_users = determine_key_accessible_users(@selected_key)
        @user_reasons = categorize_key_access_reasons(@selected_key, @accessible_users)
        @access_breakdown = group_key_users_by_type(@user_reasons)
      end
    end
  end

  private

  def determine_accessible_keys(user)
    keys = []

    # Get all projects user is member of
    projects = user.projects.active

    projects.each do |project|
      project.keys.each do |key|
        keys << key if key.whitelisted?(user, project)
      end
    end

    # Check global view all keys permission
    if user.allowed_to?({ controller: 'keys', action: 'all' }, nil, global: true)
      keys += Vault::Key.all
    end

    keys.uniq
  end

  def determine_key_accessible_users(key)
    users = []
    project = key.project

    # Admin users
    User.active.where(admin: true).each { |u| users << u }

    # Users with edit_keys permission in project
    if project.present?
      project.members.active.each do |member|
        user = member.user
        if user.allowed_to?(:edit_keys, project)
          users << user unless users.include?(user)
        end
      end
    end

    # Users in whitelist
    if key.whitelist.present?
      whitelist_ids = key.whitelist.split(',').map(&:strip).reject(&:empty?).map(&:to_i)
      User.where(id: whitelist_ids).each { |u| users << u }

      # Users in whitelisted groups
      Group.where(id: whitelist_ids).each do |group|
        group.users.each { |u| users << u unless users.include?(u) }
      end
    end

    # Tags-based (future: when tags have permissions)
    if key.tags.any?
      # Placeholder for tag-based access when implemented
    end

    users.uniq.sort_by(&:name)
  end

  def categorize_access_reasons(user, keys)
    reasons = {}

    keys.each do |key|
      reason = determine_user_key_access_reason(user, key, key.project)
      reasons[key.id] = reason
    end

    reasons
  end

  def categorize_key_access_reasons(key, users)
    reasons = {}

    users.each do |user|
      reason = determine_key_user_access_reason(key, user, key.project)
      reasons[user.id] = reason
    end

    reasons
  end

  def determine_user_key_access_reason(user, key, project)
    # 1. Admin bypass
    if user.admin?
      return {
        type: 'admin',
        reason: 'Admin user (bypass)',
        icon: '👤'
      }
    end

    # 2. Has edit_keys permission
    if project.present? && user.allowed_to?(:edit_keys, project)
      return {
        type: 'permissions',
        reason: 'Has :edit_keys permission on project',
        icon: '🔓'
      }
    end

    # 3. Whitelist (direct or via group)
    if key.whitelist.present?
      whitelist_ids = key.whitelist.split(',').map(&:strip).reject(&:empty?).map(&:to_i)

      if whitelist_ids.include?(user.id)
        return {
          type: 'whitelist',
          reason: 'Direct whitelist entry',
          source: 'user',
          icon: '✅'
        }
      end

      # Check groups
      user_group_ids = user.groups.pluck(:id)
      matched_group = whitelist_ids.find { |id| user_group_ids.include?(id) }

      if matched_group
        group = Group.find(matched_group)
        return {
          type: 'whitelist',
          reason: "Whitelisted via group: #{group.name}",
          source: "group:#{group.name}",
          icon: '✅'
        }
      end
    end

    # 4. Tags-based (future)
    if key.tags.any?
      # Placeholder for tag-based access
    end

    # Should not reach here if key.whitelisted? returned true
    {
      type: 'unknown',
      reason: 'Unknown reason',
      icon: '❓'
    }
  end

  def determine_key_user_access_reason(key, user, project)
    # 1. Admin bypass
    if user.admin?
      return {
        type: 'admin',
        reason: 'Admin user'
      }
    end

    # 2. Has edit_keys permission
    if project.present? && user.allowed_to?(:edit_keys, project)
      return {
        type: 'permissions',
        reason: 'Has :edit_keys permission on project'
      }
    end

    # 3. Whitelist (direct or via group)
    if key.whitelist.present?
      whitelist_ids = key.whitelist.split(',').map(&:strip).reject(&:empty?).map(&:to_i)

      if whitelist_ids.include?(user.id)
        return {
          type: 'whitelist',
          reason: 'Direct whitelist entry'
        }
      end

      # Check groups
      user_group_ids = user.groups.pluck(:id)
      matched_group = whitelist_ids.find { |id| user_group_ids.include?(id) }

      if matched_group
        group = Group.find(matched_group)
        return {
          type: 'whitelist',
          reason: "Whitelisted via group: #{group.name}"
        }
      end
    end

    {
      type: 'unknown',
      reason: 'Unknown reason'
    }
  end

  def group_by_access_type(reasons)
    grouped = reasons.values.group_by { |r| r[:type] }
    grouped.transform_values { |v| v }
  end

  def group_key_users_by_type(user_reasons)
    grouped = user_reasons.values.group_by { |r| r[:type] }
    grouped.transform_values { |v| v }
  end
end
