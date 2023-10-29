if Redmine::VERSION.to_s.start_with?('4')
  class CreateTags < ActiveRecord::Migration[4.2]
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
else
  class CreateTags < ActiveRecord::Migration[6.1]
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
end
