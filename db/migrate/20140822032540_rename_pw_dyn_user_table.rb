class RenamePwDynUserTable < ActiveRecord::Migration
  def change
    rename_table :pw_dyn_user, :users
  end
end
