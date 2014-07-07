# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140625052804) do

  create_table "boards", force: true do |t|
    t.string   "trello_board_id",   null: false
    t.string   "new_list_id"
    t.string   "wip_list_id"
    t.string   "done_list_id"
    t.string   "name",              null: false
    t.string   "short_url",         null: false
    t.string   "trello_webhook_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "boards", ["trello_board_id"], name: "index_boards_on_trello_board_id", unique: true, using: :btree

  create_table "card_tags", force: true do |t|
    t.integer  "card_id"
    t.integer  "target_id"
    t.string   "target_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "card_tags", ["card_id", "target_id", "target_type"], name: "index_card_tags_on_card_id_and_target_id_and_target_type", unique: true, using: :btree
  add_index "card_tags", ["target_id", "target_type"], name: "index_card_tags_on_target_id_and_target_type", using: :btree

  create_table "cards", force: true do |t|
    t.string   "trello_id"
    t.string   "trello_list_id"
    t.string   "label"
    t.boolean  "archived",       default: false
    t.text     "data"
    t.datetime "due"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "board_id"
    t.boolean  "deleted",        default: false
  end

  add_index "cards", ["board_id"], name: "index_cards_on_board_id", using: :btree
  add_index "cards", ["deleted"], name: "index_cards_on_deleted", using: :btree
  add_index "cards", ["label", "archived"], name: "index_cards_on_label_and_archived", using: :btree
  add_index "cards", ["trello_id"], name: "index_cards_on_trello_id", unique: true, using: :btree
  add_index "cards", ["trello_list_id", "archived"], name: "index_cards_on_trello_list_id_and_archived", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "deployments", force: true do |t|
    t.integer  "server_id"
    t.integer  "project_id"
    t.string   "login_user"
    t.integer  "port"
    t.string   "deployment_path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "deployment_name"
    t.string   "settings_hash"
  end

  add_index "deployments", ["deployment_name"], name: "index_deployments_on_deployment_name", using: :btree
  add_index "deployments", ["project_id"], name: "index_deployments_on_project_id", using: :btree
  add_index "deployments", ["server_id"], name: "index_deployments_on_server_id", using: :btree

  create_table "jobs", force: true do |t|
    t.integer  "status"
    t.string   "requested_by"
    t.string   "authorized_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "deployment_id"
    t.integer  "job_type"
    t.integer  "project_id"
  end

  add_index "jobs", ["authorized_by"], name: "index_jobs_on_authorized_by", using: :btree
  add_index "jobs", ["deployment_id"], name: "index_jobs_on_deployment_id", using: :btree
  add_index "jobs", ["project_id"], name: "index_jobs_on_project_id", using: :btree
  add_index "jobs", ["requested_by"], name: "index_jobs_on_requested_by", using: :btree
  add_index "jobs", ["status"], name: "index_jobs_on_status", using: :btree

  create_table "projects", force: true do |t|
    t.string   "project_name"
    t.text     "git_url"
    t.string   "branch"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects_servers", id: false, force: true do |t|
    t.integer "project_id"
    t.integer "server_id"
  end

  add_index "projects_servers", ["project_id"], name: "index_projects_servers_on_project_id", using: :btree
  add_index "projects_servers", ["server_id"], name: "index_projects_servers_on_server_id", using: :btree

  create_table "reports", force: true do |t|
    t.string   "report_type"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "reports", ["owner_id", "owner_type"], name: "index_reports_on_owner_id_and_owner_type", using: :btree
  add_index "reports", ["report_type"], name: "index_reports_on_report_type", using: :btree

  create_table "server_logs", force: true do |t|
    t.integer  "server_id"
    t.string   "timestamp"
    t.text     "log"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "server_logs", ["server_id", "timestamp"], name: "index_server_logs_on_server_id_and_timestamp", unique: true, using: :btree

  create_table "servers", force: true do |t|
    t.string   "hostname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "manually_created", default: false
    t.boolean  "logging"
    t.integer  "port"
    t.string   "login_user"
  end

  add_index "servers", ["hostname"], name: "index_servers_on_hostname", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
