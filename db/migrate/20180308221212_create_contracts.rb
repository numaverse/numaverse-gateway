class CreateContracts < ActiveRecord::Migration[5.1]
  def change
    create_table :contracts do |t|
      t.integer :name
      t.string :address

      t.timestamps
    end
  end
end
