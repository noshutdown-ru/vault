class AddWhitelistToKeys < ActiveRecord::Migration[6.1]
  def change
    add_column :keys, :whitelist, :string, default: ''
  end
end
