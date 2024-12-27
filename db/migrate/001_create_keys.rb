class CreateKeys < ActiveRecord::Migration[6.1]
  def change
    create_table :keys do |t|
      t.belongs_to :project, index: true
      t.string :lock
      t.string :body
    end
  end
end

