class AddAasmStates < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :aasm_state, :string
    add_column :accounts, :aasm_state, :string
    add_column :favorites, :aasm_state, :string
    add_column :tips, :aasm_state, :string
    add_column :follows, :aasm_state, :string
  end
end
