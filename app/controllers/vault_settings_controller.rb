require 'csv'

class VaultSettingsController < ApplicationController
  unloadable
  menu_item :vault_settings

  layout 'admin'
  before_filter :require_admin

  def index

  end

  def backup

    @csv_string = CSV.generate do |csv|
      csv << Vault::Key.attribute_names
      Vault::Key.all.each do |user|
        csv << user.attributes.values
      end
    end

    fname = "keys_#{DateTime.now.to_s}.csv"
    send_data @csv_string,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=#{fname}"

  end

  def restore
    Vault::Key.import(params[:file])
    redirect_to '/vault_settings', notice: "Products imported."
  end

end