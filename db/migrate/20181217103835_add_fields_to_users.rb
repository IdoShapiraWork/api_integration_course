class AddFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :email_playground, :string
  end
end
