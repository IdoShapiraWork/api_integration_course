class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email
      t.string :playground
      t.string :username
      t.string :avatar
      t.string :role
      t.integer :points
      t.integer :verified

      t.timestamps
    end
  end
end
