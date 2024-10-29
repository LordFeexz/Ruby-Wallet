class CreateWallet < ActiveRecord::Migration[7.2]
  def change
    create_table :wallets do |t|
      t.integer :reference_id, null: false
      t.string :reference_type, null: false
      t.decimal :balance, precision: 15, scale: 2, default: 0.0
      t.timestamps
    end
  end
end
