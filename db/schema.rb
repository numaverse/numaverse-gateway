# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180328233947) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "address"
    t.integer "foreign_id"
    t.string "foreign_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "uuid"
    t.decimal "balance_nuwei", precision: 1000, default: "0", null: false
    t.string "balance_currency", default: "NUMA", null: false
    t.boolean "is_user_pool", default: false, null: false
    t.text "bio"
    t.string "avatar_ipfs_hash"
    t.string "display_name"
    t.string "ipfs_hash"
    t.string "location"
    t.string "aasm_state"
  end

  create_table "blocks", force: :cascade do |t|
    t.string "address"
    t.string "miner"
    t.string "nonce"
    t.datetime "timestamp"
    t.integer "number"
    t.integer "difficulty"
    t.integer "size"
    t.integer "gas_limit"
    t.integer "gas_used"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "transactions_count"
  end

  create_table "contract_events", force: :cascade do |t|
    t.integer "contract_id"
    t.string "event_name"
    t.integer "tx_id"
    t.integer "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contracts", force: :cascade do |t|
    t.integer "name"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creation_tx_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.integer "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ipfs_hash"
    t.integer "foreign_id"
    t.datetime "hidden_at"
    t.integer "account_id"
    t.string "aasm_state"
  end

  create_table "federated_accounts", force: :cascade do |t|
    t.integer "local_account_id"
    t.json "object_data"
    t.string "federated_id"
    t.text "public_key"
    t.text "private_key"
    t.string "username"
    t.string "avatar_url"
    t.string "display_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "shared_inbox_url"
    t.string "inbox_url"
    t.string "outbox_url"
    t.string "followers_url"
    t.string "following_url"
  end

  create_table "federated_follows", force: :cascade do |t|
    t.string "federated_id"
    t.integer "from_account_id"
    t.integer "to_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "federated_messages", force: :cascade do |t|
    t.integer "local_account_id"
    t.integer "federated_account_id"
    t.json "object_data"
    t.integer "local_message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "federated_versions", force: :cascade do |t|
    t.integer "action_type"
    t.integer "federated_message_id"
    t.json "object_changes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "local_message_id"
  end

  create_table "follows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "to_account_id"
    t.integer "from_account_id"
    t.string "ipfs_hash"
    t.integer "foreign_id"
    t.datetime "hidden_at"
    t.string "aasm_state"
  end

  create_table "gutentag_taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id", null: false
    t.integer "taggable_id", null: false
    t.string "taggable_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_gutentag_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id", "tag_id"], name: "unique_taggings", unique: true
    t.index ["taggable_type", "taggable_id"], name: "index_gutentag_taggings_on_taggable_type_and_taggable_id"
  end

  create_table "gutentag_tags", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0, null: false
    t.index ["name"], name: "index_gutentag_tags_on_name", unique: true
    t.index ["taggings_count"], name: "index_gutentag_tags_on_taggings_count"
  end

  create_table "messages", force: :cascade do |t|
    t.text "body"
    t.bigint "account_id"
    t.datetime "foreign_created_at"
    t.integer "foreign_block_created"
    t.integer "foreign_id"
    t.text "foreign_data"
    t.datetime "foreign_updated_at"
    t.integer "foreign_block_updated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "tx_data"
    t.string "tx_hash"
    t.string "title"
    t.text "tldr"
    t.json "foreign_data_json"
    t.text "sanitized_body"
    t.integer "user_id"
    t.string "dat_folder_id"
    t.string "uuid"
    t.datetime "hidden_at"
    t.integer "favorites_count", default: 0
    t.integer "repost_id"
    t.integer "repost_count", default: 0
    t.integer "reply_count", default: 0
    t.integer "reply_to_id"
    t.string "ipfs_hash"
    t.integer "json_schema"
    t.string "json_schema_other"
    t.string "aasm_state"
    t.index ["account_id"], name: "index_messages_on_account_id"
  end

  create_table "tips", force: :cascade do |t|
    t.integer "tx_id"
    t.string "tx_hash"
    t.integer "message_id"
    t.integer "to_account_id"
    t.integer "from_account_id"
    t.integer "to_message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ipfs_hash"
    t.integer "foreign_id"
    t.string "aasm_state"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "block_hash"
    t.integer "block_number"
    t.string "from"
    t.string "to"
    t.integer "gas"
    t.decimal "gas_price", precision: 32
    t.string "address"
    t.string "nonce"
    t.text "input"
    t.integer "to_account_id"
    t.integer "from_account_id"
    t.integer "block_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "value_nuwei", precision: 32, default: "0", null: false
    t.string "value_currency", default: "NUMA", null: false
    t.integer "message_id"
    t.integer "transactable_id"
    t.string "transactable_type"
  end

  create_table "user_accounts", force: :cascade do |t|
    t.integer "account_id"
    t.integer "user_id"
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "messages", "accounts"
end
