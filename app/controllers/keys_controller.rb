class KeysController < ApplicationController
  before_action :find_project_by_project_id, except: [:all, :edit_orphaned, :update_orphaned, :destroy_orphaned]
  before_action :authorize, except: [:all, :edit_orphaned, :update_orphaned, :destroy_orphaned, :download]
  before_action :find_key, only: [:show, :edit, :update, :destroy, :copy]
  before_action :set_audit_user, only: [:create, :update, :update_orphaned, :destroy, :destroy_orphaned]
  accept_api_auth :index, :show, :create, :update, :destroy, :all

  helper :sort
  include SortHelper
  helper :queries
  include QueriesHelper

  def index
    return unless prepare_query
    render_query
  end

  def all
    unless User.current.allowed_to?({ :controller => 'keys', :action => 'all' }, nil, :global => true)
      render_error t("error.user.not_allowed")
      return
    end

    @project = nil

    return unless prepare_query
    render_query
  end

  def new
    @key = Vault::Key.new(project: @project)
    @key.whitelist = ""
  end

  def copy
    if !@key.whitelisted?(User.current, @project)
      render_error t("error.key.not_whitelisted")
      return
    end

    @key = Vault::Key.new(project: @key.project, name: @key.name, login: @key.login, type: @key.type)
    render action: 'new'
  end

  def create
    save_file if key_params[:file]
    @key = Vault::Key.new
    @key.safe_attributes = key_params.except(:tags)
    @key.project = @project
    @key.audit_user = User.current

    self.update_wishlist

    respond_to do |format|
      if @key.save
        @key.tags = key_params[:tags]
        format.html { redirect_to project_keys_path(@project), notice: t('notice.key.create.success') }
        format.json { render json: { key: @key }, status: :created, location: project_key_path(@project, @key) }
      else
        format.html { render action: 'new' }
        format.json { render json: { errors: @key.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def update
    save_file if key_params[:file]
    respond_to do |format|
      self.update_wishlist
      @key.safe_attributes = key_params.except(:tags)
      @key.audit_user = User.current

      if @key.update(key_params.except(:tags))
        @key.tags = key_params[:tags]
        format.html { redirect_to project_keys_path(@project), notice: t('notice.key.update.success') }
        format.json { render json: { key: @key }, status: :ok }
      else
        format.html { render action: 'edit' }
        format.json { render json: { errors: @key.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def update_wishlist
    if User.current.allowed_to?(:manage_whitelist_keys, @key.project)
      if params[:whitelist].blank?
        @key.whitelist = ""
      else
        @key.whitelist = params[:whitelist].join(",")
      end
    end
  end

  def edit
    if !@key.whitelisted?(User.current, @project)
      render_error t("error.key.not_whitelisted")
      return
    else
      @key.decrypt!
      respond_to do |format|
        format.html { render action: 'edit' }
      end
    end
  end

  def show
    if !@key.whitelisted?(User.current, @project)
      render_error t("error.key.not_whitelisted")
      return
    else
      @key.decrypt!
      respond_to do |format|
        format.html { render action: 'show' }
        format.json { render json: { key: @key }, status: :ok }
      end
    end
  end

  def destroy
    @key.audit_user = User.current
    @key.destroy
    respond_to do |format|
      format.html do
        redirect_to project_keys_path(@project)
        flash[:notice] = t('notice.key.delete.success')
      end
      format.json { render json: {}, status: :ok }
    end
  end

  def download
    @key = Vault::Key.find(params[:id])
    @project = Project.find(params[:project_id])

    unless @key.project_id == @project.id
      render_error t('alert.key.not_found')
      return
    end

    unless User.current.allowed_to?(:download_keys, @project)
      render_error t("error.user.not_allowed")
      return
    end

    if !@key.whitelisted?(User.current, @project)
      render_error t("error.key.not_whitelisted")
      return
    end

    if @key.file.present?
      file_path = "#{Vault::KEYFILES_DIR}/#{@key.file}"

      if File.exist?(file_path)
        # Get file content (automatically decrypts if encrypted)
        file_content = @key.file_content

        if file_content
          # Log the download in audit log
          Vault::KeyAuditLog.log_action(@key, 'view', User.current)

          # Send file content with proper headers
          send_data file_content, filename: @key.name, type: 'application/octet-stream'
        else
          render_error "Failed to read file"
        end
      else
        render_error "File not found"
      end
    else
      render_error "File not found"
    end
  end

  # ==================== Orphaned Key Operations ====================
  # Admin-only operations for keys whose projects have been deleted.
  # Used in /keys/all view to manage and reassign orphaned keys.
  # ====================================================================

  def edit_orphaned
    unless User.current.admin?
      render_error t("error.user.not_allowed")
      return
    end

    @key = Vault::Key.find(params[:id])
    unless @key.project.nil?
      render_error t("error.key.not_orphaned")
      return
    end

    @key.decrypt!
    @projects = Project.active
    render 'edit_orphaned'
  end

  def update_orphaned
    unless User.current.admin?
      render_error t("error.user.not_allowed")
      return
    end

    @key = Vault::Key.find(params[:id])
    unless @key.project.nil?
      render_error t("error.key.not_orphaned")
      return
    end

    # Try to get project_id from different places
    project_id = params[:project_id]
    if !project_id && params[@key.type.underscore].present?
      project_id = params[@key.type.underscore][:project_id]
    end

    if project_id.present?
      @key.project_id = project_id
      @key.audit_user = User.current
      if @key.save
        redirect_to keys_all_path, notice: t('notice.key.update.success')
      else
        @projects = Project.active
        render 'edit_orphaned'
      end
    else
      @projects = Project.active
      @key.errors.add(:project_id, t("error.project.required"))
      render 'edit_orphaned'
    end
  end

  def destroy_orphaned
    unless User.current.admin?
      render_error t("error.user.not_allowed")
      return
    end

    @key = Vault::Key.find(params[:id])
    if @key.project.nil?
      @key.audit_user = User.current
      @key.destroy
      respond_to do |format|
        format.html do
          redirect_to keys_all_path
          flash[:notice] = t('notice.key.delete.success')
        end
        format.json { render json: {}, status: :ok }
      end
    else
      render_error t("error.key.not_orphaned")
    end
  end
  # ===================== End Orphaned Key Operations =====================

  private

  def prepare_query
    unless Setting.plugin_vault['use_redmine_encryption'] || Setting.plugin_vault['use_null_encryption'] || Setting.plugin_vault['encryption_key'].present?
      render_error t("error.key.not_set")
      return false
    end

    retrieve_query(Vault::KeyQuery)
    sort_init(@query.sort_criteria.empty? ? [['name', 'asc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    @query.sort_criteria = sort_criteria.to_a
    @search = params[:search].to_s

    return unless @query.valid?

    @limit = per_page_option

    scoped_keys = @query.results_scope(
      search: @search,
      order: sort_clause
    )

    all_visible_keys = scoped_keys.to_a.select do |key|
      key.whitelisted?(User.current, @project || key.project)
    end

    @key_count = all_visible_keys.size
    @key_pages = Paginator.new(@key_count, @limit, params[:page])
    @offset ||= @key_pages.offset
    @keys = all_visible_keys.drop(@offset).first(@limit)
    @keys.each(&:decrypt!)

    true
  end

  def render_query
    if @query.valid?
      respond_to do |format|
        format.html do
          if request.xhr?
            render partial: 'list', layout: false
          elsif @project.blank?
            render template: 'keys/index'
          end
        end
        format.pdf do
          if @project.present?
            unless User.current.allowed_to?(:export_keys, @project)
              render_error t("error.user.not_allowed")
              return
            end
          elsif !User.current.allowed_to?({ :controller => 'keys', :action => 'all' }, nil, :global => true)
            render_error t("error.user.not_allowed")
            return
          end

          render template: 'keys/index' if @project.blank?
        end
        format.json { render json: { keys: @keys } }
      end
    else
      respond_to do |format|
        format.html { render template: 'keys/index', layout: !request.xhr? }
        format.any(:pdf) { render plain: '' }
        format.json { render_validation_errors(@query) }
      end
    end
  end

  def set_audit_user
    # Placeholder for audit user - actual assignment happens in each action
  end

  def find_key
    @key = Vault::Key.find(params[:id])
    unless @key.project_id == @project.id
      redirect_to project_keys_path(@project), notice: t('alert.key.not_found')
    end
  end

  def key_params
    params.require(:vault_key).permit(:type, :name, :body, :login, :file, :url, :comment, :tags)
  end

  def save_file
    name = SecureRandom.uuid
    File.open("#{Vault::KEYFILES_DIR}/#{name}", "wb") { |f| f.write(key_params[:file].read) }
    params['vault_key']['file'] = name
  end

  def projects_for_jump_box(user = User.current)
    if user.logged?
      user.projects.active.select(:id, :name, :identifier, :lft, :rgt).to_a
    else
      []
    end
  end
end
