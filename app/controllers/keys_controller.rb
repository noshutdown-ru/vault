class KeysController < ApplicationController
  unloadable

  before_action :find_project_by_project_id
  before_action :authorize
  before_action :find_key, only: [ :show, :edit, :update, :destroy, :copy ]
  before_action :find_keys, only: [ :context_menu ]

  helper :sort
  include SortHelper
  helper ContextMenusHelper

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

    @query = params[:query]
    @search_fild = params[:search_fild]

    if @query
      if @query.match(/#/)
        tag_string = (@query.match(/(#)([^,]+)/))[2]
        tag = Vault::Tag.find_by_name(tag_string)
        @keys = tag.nil? ? nil : tag.keys.where(project: @project)
      else

        if params[:search_fild] == 'name'
          @keys = @project.keys.where('`name` LIKE ?', "%#{@query}%")
        elsif params[:search_fild] == 'url'
          @keys = @project.keys.where('`url` LIKE ?', "%#{@query}%")
        elsif params[:search_fild] == 'tag'
          tag = Vault::Tag.find_by_name(@query)
          @keys = tag.nil? ? nil : tag.keys.where(project: @project)
        end

      end
    else
      @keys = @project.keys
    end

    @keys = @keys.order(sort_clause) unless @keys.nil?

    @keys = [] if @keys.nil? #hack for decryption

    @limit = per_page_option
    @key_count = @keys.count
    @key_pages = Paginator.new @key_count, @limit, params[:page]
    @offset ||= @key_pages.offset

    if @key_count > 0
      @keys = @keys.offset(@offset).limit(@limit)
    end

    @keys = @keys.select { |key| key.whitelisted?(User,@project) }

    @keys.map(&:decrypt!)
  end

  def new
    @key = Vault::Key.new(project: @project)
  end

  def copy
    @key = Vault::Key.new(project: @key.project, name: @key.name, login: @key.login, type: @key.type)
    render action: 'new'
  end

  def create
    save_file if key_params[:file]
    @key = Vault::Key.new(key_params)
    @key.project = @project

    @key.tags = Vault::Tag.create_from_string(key_params[:tags])

    self.update_wishlist

    respond_to do |format|
      if @key.save
        format.html { redirect_to project_keys_path(@project), notice: t('notice.key.create.success') }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def update
    save_file if key_params[:file]
    respond_to do |format|

      self.update_wishlist

      if @key.update_attributes(params[:vault_key])
        @key.tags = Vault::Tag.create_from_string(key_params[:tags])
        format.html { redirect_to project_keys_path(@project), notice: t('notice.key.update.success') }
      else
        format.html { render action: 'edit'}
      end
    end
  end

  def update_wishlist
    if params[:whitelist] && User.current.allowed_to?(:manage_whitelist_keys, @key.project)
      if params[:whitelist].blank?
          @key.whitelist = ""
      else
          @key.whitelist =  params[:whitelist].join(",")
      end
    end
  end

  def edit
    @key.decrypt!
    respond_to do |format|
      format.html { render action: 'edit'}
    end
  end

  def show
    @key.decrypt!
    respond_to do |format|
      format.html { render action: 'show'}
    end
  end

  def destroy
    Vault::Key.find(params[:id]).destroy
    redirect_to project_keys_path(@project)
    flash[:notice] = t('notice.key.delete.success')
  end

  def context_menu
    #FIXME
    @keys.map(&:decrypt!)
    render layout: false
  end

  private

  def find_key
    @key=Vault::Key.find(params[:id])
    unless @key.project_id == @project.id
      redirect_to project_keys_path(@project), notice: t('alert.key.not_found')
    end
  end

  def find_keys
    @keys=Vault::Key.find(params[:ids])
    unless @keys.all? { |k| k.project_id == @project.id } 
      redirect_to project_keys_path(@project), notice: t('alert.key.not_found')
    end
  end

  def key_params
    params.require(:vault_key).permit(:type, :name, :body, :login, :file, :url, :comment, :tags)
  end

  def index_params
    params.permit('query')
  end

  def save_file
    name = SecureRandom.uuid
    File.open("#{Vault::KEYFILES_DIR}/#{name}", "wb") { |f| f.write(key_params[:file].read) }
    params['vault_key']['file'] = name
  end

end
