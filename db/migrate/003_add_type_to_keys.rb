class AddTypeToKeys < ActiveRecord::Migration
  def change
    add_column :keys, :type, :string, default: 'Password'
  end
end
