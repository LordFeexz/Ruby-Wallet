class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :username, null: false, index: { unique: true, name: 'unique_username' }
      t.string :password, null: false
      t.timestamps
    end
  end
end
