class AddTagIdToPolicies < ActiveRecord::Migration[6.0]
  def change
    add_column :policies, :tag_id, :integer
  end
end
