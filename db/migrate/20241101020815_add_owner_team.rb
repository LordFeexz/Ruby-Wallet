class AddOwnerTeam < ActiveRecord::Migration[7.2]
  def change
    add_reference :teams, :owner, foreign_key: { to_table: :users, on_delete: :nullify, on_update: :cascade }
  end
end
