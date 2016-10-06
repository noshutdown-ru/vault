class AddWhitelistToKeys < ActiveRecord::Migration
  def change
    add_column :keys, :whitelist, :string, default: ''
  end
end
