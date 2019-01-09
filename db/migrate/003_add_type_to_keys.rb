class AddTypeToKeys < ActiveRecord::Migration[4.2]
  def change
    add_column :keys, :type, :string, default: 'Password'
  end
end
