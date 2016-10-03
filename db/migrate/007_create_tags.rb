class CreateTags < ActiveRecord::Migration
  def change
    create_table :vault_tags do |t|
      t.string :name, index: true
    end

    create_table :keys_vault_tags, id: false do |t|
      t.belongs_to :key, index: true
      t.belongs_to :tag, index: true
    end
  end
end
