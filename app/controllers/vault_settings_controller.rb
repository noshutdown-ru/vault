require 'csv'
require 'zip'

class VaultSettingsController < ApplicationController
  unloadable
  menu_item :vault_settings

  layout 'admin'
  before_action :require_admin

  def index

  end

  def save
    if params[:settings][:encryption_key].length != 16 and params[:settings][:encryption_key].length != 0
      redirect_to vault_settings_path, :flash => { :error =>  t('error.key.length') }
      return
    end

    Setting.send "plugin_vault=", params[:settings]
    redirect_to vault_settings_path , notice: t('notice.settings.saved')
  end

  def backup
    # FIXME
    @csv_string = CSV.generate do |csv|
      csv << Vault::Key.attribute_names
      Vault::Key.all.each do |key|
        csv << key.attributes.values
      end
    end

    @csv_tag_string = CSV.generate do |csv|
      csv << Vault::Tag.attribute_names
      Vault::Tag.all.each do |tag|
        csv << tag.attributes.values
      end
    end

    @csv_tag_keys_string = CSV.generate do |csv|
      csv << Vault::KeysVaultTags.attribute_names
      Vault::KeysVaultTags.all.each do |tag|
        csv << tag.attributes.values
      end
    end

    fname = "backup.zip"
    temp_file = Tempfile.new(fname)
    tmp_fname = temp_file.path
    temp_file.close

    Zip::File.open(tmp_fname, Zip::File::CREATE) do |zip_file|
      zip_file.file.open('keys.csv', 'w') { |f1| f1 << @csv_string }
      zip_file.file.open('tags.csv', 'w') { |f2| f2 << @csv_tag_string }
      zip_file.file.open('keys_tags.csv', 'w') { |f3| f3 << @csv_tag_keys_string }
    end

    zip_data = IO.binread(tmp_fname)

    send_data zip_data,
      :type => 'application/zip',
      :disposition => "attachment; filename=#{fname}"

  end

  def restore
    # FIXME have problem with not uniq record, move logic to module

    Zip::File.open(params[:file].tempfile.to_path.to_s) do |zipfile|
      zipfile.each do |file|
        if file.name == 'keys.csv'
          tempfile = Tempfile.new('keys.csv')
          file.extract(tempfile.path) { true }
          Vault::Key.import(tempfile)
        end
        if file.name == 'tags.csv'
          tempfile = Tempfile.new('tags.csv')
          file.extract(tempfile.path) { true }

          csv_text = File.read(tempfile.path)
          csv = CSV.parse(csv_text, :headers => true)
          csv.each do |row|
            Vault::Tag.create(row.to_hash)
          end

        end
        if file.name == 'keys_tags.csv'
          tempfile = Tempfile.new('keys_tags.csv')
          file.extract(tempfile.path) { true }

          csv_text = File.read(tempfile.path)
          csv = CSV.parse(csv_text, :headers => true)
          csv.each do |row|
            Vault::KeysVaultTags.create(row.to_hash)
          end

        end
      end
    end

    redirect_to vault_settings_path, notice: t('notice.settings.keys_restore')
  end

end
