# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_14_122042) do
  create_table "addresses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "address_type", null: false
    t.datetime "created_at"
    t.datetime "deleted_at"
    t.string "deleted_by"
    t.string "name", null: false
    t.text "notes"
    t.datetime "updated_at"
    t.index ["address_type", "name"], name: "idx_address_type_name_unique", unique: true
    t.index ["deleted_at"], name: "index_addresses_on_deleted_at"
  end

  create_table "categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.decimal "amount_partner", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "amount_water", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.string "created_by"
    t.datetime "deleted_at"
    t.string "deleted_by"
    t.text "descricao"
    t.boolean "has_hydrometer", default: false
    t.string "member_type", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.string "updated_by"
    t.index ["deleted_at", "id"], name: "idx_categories_deleted_at_id"
    t.index ["deleted_at"], name: "idx_category_deleted_at"
    t.index ["member_type"], name: "idx_category_member_type"
    t.index ["name", "member_type"], name: "idx_category_name_member_type", unique: true
  end

  create_table "connections", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "address_id", null: false
    t.bigint "category_id", null: false
    t.virtual "connection_key", type: :string, as: "if((`deleted_at` is null),concat(`address_id`,_utf8mb4'-',`number`),NULL)", stored: true
    t.datetime "created_at", null: false
    t.string "created_by"
    t.datetime "deleted_at"
    t.string "deleted_by"
    t.bigint "member_id", null: false
    t.string "number"
    t.boolean "partner_exclusive", default: false, null: false
    t.date "registration_date"
    t.datetime "updated_at", null: false
    t.string "updated_by"
    t.index ["address_id"], name: "idx_connection_address_id"
    t.index ["category_id"], name: "idx_connection_category_id"
    t.index ["connection_key"], name: "idx_connections_key", unique: true
    t.index ["deleted_at", "address_id"], name: "idx_connections_deleted_at_address_id"
    t.index ["deleted_at"], name: "idx_connections_deleted_at"
    t.index ["member_id"], name: "idx_connection_member_id"
  end

  create_table "invoices", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.decimal "amount_partner", precision: 10, scale: 2
    t.decimal "amount_water", precision: 10, scale: 2
    t.bigint "connection_id", null: false
    t.datetime "created_at", null: false
    t.string "created_by"
    t.datetime "deleted_at"
    t.string "deleted_by"
    t.date "due_date", null: false
    t.datetime "paid_at"
    t.date "reference_date"
    t.datetime "updated_at", null: false
    t.string "updated_by"
    t.index ["connection_id", "reference_date"], name: "idx_invoices_unique_connection_reference", unique: true
    t.index ["connection_id"], name: "index_invoices_on_connection_id"
    t.index ["deleted_at"], name: "index_invoices_on_deleted_at"
    t.index ["due_date"], name: "index_invoices_on_due_date"
    t.index ["reference_date"], name: "index_invoices_on_reference_date"
  end

  create_table "members", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "created_by"
    t.datetime "deleted_at"
    t.string "deleted_by"
    t.string "document"
    t.integer "member_number"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.string "updated_by"
    t.boolean "voter", default: false, null: false
    t.index ["deleted_at", "name"], name: "idx_members_deleted_at_name"
    t.index ["deleted_at"], name: "idx_members_deleted_at"
    t.index ["document"], name: "idx_members_document_unique", unique: true
    t.index ["name"], name: "idx_members_name"
  end

  create_table "water_analyses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.decimal "analyzed_value", precision: 10, scale: 4
    t.decimal "conformity_value", precision: 10, scale: 4
    t.datetime "created_at", null: false
    t.string "created_by"
    t.datetime "deleted_at"
    t.string "deleted_by"
    t.string "parameter", null: false
    t.date "reference_date", null: false
    t.decimal "required_value", precision: 10, scale: 4
    t.datetime "updated_at", null: false
    t.string "updated_by"
    t.index ["deleted_at"], name: "idx_water_analyses_deleted_at"
    t.index ["parameter"], name: "idx_water_analyses_parameter"
    t.index ["reference_date", "parameter"], name: "idx_water_analyses_reference_parameter_unique", unique: true
    t.index ["reference_date"], name: "idx_water_analyses_reference_date"
  end

  add_foreign_key "connections", "addresses"
  add_foreign_key "connections", "categories"
  add_foreign_key "connections", "members"
  add_foreign_key "invoices", "connections"
end
