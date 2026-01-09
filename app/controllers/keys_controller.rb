class KeysController < ApplicationController
  before_action :find_project_by_project_id, except: [:all, :edit_orphaned, :update_orphaned, :destroy_orphaned]
  before_action :authorize, except: [:all, :edit_orphaned, :update_orphaned, :destroy_orphaned]
  before_action :find_key, only: [:show, :edit, :update, :destroy, :copy]
  accept_api_auth :index, :show, :create, :update, :destroy

  helper :sort
  include SortHelper

  def index
    unless Setting.plugin_vault['use_redmine_encryption'] ||
      Setting.plugin_vault['use_null_encryption']
      if not Setting.plugin_vault['encryption_key'] or Setting.plugin_vault['encryption_key'].empty?
        render_error t("error.key.not_set")
        return
      end
    end

    sort_init 'name', 'asc'
    sort_update 'name' => "#{Vault::Key.table_name}.name"

    @keys = @project.keys
    @keys = @keys.order(sort_clause)
    @keys = @keys.select { |key| key.whitelisted?(User.current, @project) }
    @keys = [] if @keys.nil? # hack for decryption

    @limit = per_page_option
    @key_count = @keys.count
    @key_pages = Paginator.new @key_count, @limit, params[:page]
    @offset ||= @key_pages.offset

    if @key_count > 0
      @keys = @keys.drop(@offset).first(@limit)
    end

    @keys.map(&:decrypt!)

    respond_to do |format|
      format.html
      format.pdf
      format.json { render json: @keys }
    end
  end

  def all
    unless User.current.allowed_to?({ :controller => 'keys', :action => 'all' }, nil, :global => true)
      render_error t("error.user.not_allowed")
      return
    end

    unless Setting.plugin_vault['use_redmine_encryption'] or Setting.plugin_vault['use_null_encryption']
      if not Setting.plugin_vault['encryption_key'] or Setting.plugin_vault['encryption_key'].empty?
        render_error t("error.key.not_set")
        return
      end
    end

    if User.current.admin?
      @projects = Project.active
    else
      @projects = projects_for_jump_box(User.current)
    end

    sort_init 'name', 'asc'
    sort_update 'name' => "#{Vault::Key.table_name}.name"

    @keys = Vault::Key.all
    @keys = @keys.order(sort_clause)
    @keys = @keys.select { |key| key.whitelisted?(User.current, key.project) }
    @keys = [] if @keys.nil? # hack for decryption

    @limit = per_page_option
    @key_count = @keys.count
    @key_pages = Paginator.new @key_count, @limit, params[:page]
    @offset ||= @key_pages.offset

    if @key_count > 0
      @keys = @keys.drop(@offset).first(@limit)
    end

    @keys.map(&:decrypt!)

    respond_to do |format|
      format.html
      format.pdf
      format.json { render json: @keys }
    end
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
    @key.tags = key_params[:tags]
    @key.project = @project
    
    self.update_wishlist

    respond_to do |format|
      if @key.save
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

      if @key.update(key_params)
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
    Vault::Key.find(params[:id]).destroy
    respond_to do |format|
      format.html do
        redirect_to project_keys_path(@project)
        flash[:notice] = t('notice.key.delete.success')
      end
      format.json { render json: {}, status: :ok }
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
