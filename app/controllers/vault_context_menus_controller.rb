class VaultContextMenusController < ApplicationController

  helper ContextMenusHelper
  before_action :find_key, only: [:keys]

  def keys
    render layout: false
  end

end
