class RemoveDiscardedAdminAccessFlag < ActiveRecord::Migration[8.1]
  def up
    remove_column :users, :admin_access, :boolean if column_exists?(:users, :admin_access)
  end

  def down
    add_column :users, :admin_access, :boolean, default: false, null: false unless column_exists?(:users, :admin_access)
  end
end
