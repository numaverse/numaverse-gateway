class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.string :address
      t.integer :foreign_id
      t.string :foreign_data

      t.timestamps
    end
  end
end
