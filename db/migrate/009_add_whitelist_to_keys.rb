class AddWhitelistToKeys < ActiveRecord::Migration[4.2]
  def change
    add_column :keys, :whitelist, :string, default: ''
  end
end
