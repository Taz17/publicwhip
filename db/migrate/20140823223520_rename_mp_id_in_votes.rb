class RenameMpIdInVotes < ActiveRecord::Migration
  def change
    rename_column :votes, :mp_id, :member_id
  end
end
