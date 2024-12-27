class AddColorToVaultTags < ActiveRecord::Migration[6.1]
  def change
    add_column :vault_tags, :color, :string, default: '#8dbb9e'
  end
end