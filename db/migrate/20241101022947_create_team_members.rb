class CreateTeamMembers < ActiveRecord::Migration[7.2]
  def change
    create_table :team_members do |t|
      t.references :team, null: false, foreign_key: { on_delete: :cascade, on_update: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade, on_update: :cascade }
      t.integer :role, null: false
      t.timestamps
    end
    add_index :team_members, [ :team_id, :user_id ], unique: true
  end
end
