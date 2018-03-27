class CreateContractEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :contract_events do |t|
      t.integer :contract_id
      t.string :event_name
      t.integer :tx_id
      t.integer :message_id

      t.timestamps
    end
  end
end
