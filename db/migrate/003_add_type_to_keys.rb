class AddTypeToKeys < ActiveRecord::Migration[6.1]
  def change
    add_column :keys, :type, :string, default: 'Password'
  end
end
