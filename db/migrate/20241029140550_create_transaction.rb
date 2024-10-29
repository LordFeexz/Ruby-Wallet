class CreateTransaction < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: { on_delete: :nullify, on_update: :cascade }
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.string :transaction_type, null: false
      t.text :description
      t.jsonb :context, null: false, default: {}
      t.timestamps
    end
  end
end
