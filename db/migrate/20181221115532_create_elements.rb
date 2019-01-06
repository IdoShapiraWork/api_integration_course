class CreateElements < ActiveRecord::Migration[5.2]
  def change
    create_table :elements do |t|
      t.string :name
      t.float :type
      t.float :location_x
      t.float :location_y
      t.string :expiration_date

      t.timestamps
    end
  end
end
