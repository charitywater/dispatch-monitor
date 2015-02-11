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

ActiveRecord::Schema.define(version: 20150210202219) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "program_id"
    t.integer  "role",                   default: 0,     null: false
    t.string   "name",                                   null: false
    t.string   "timezone",               default: "UTC", null: false
    t.boolean  "weekly_subscription"
  end

  add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree
  add_index "accounts", ["program_id"], name: "index_accounts_on_program_id", using: :btree
  add_index "accounts", ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree

  create_table "activities", force: true do |t|
    t.integer  "project_id",                          null: false
    t.datetime "happened_at",                         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "activity_type",                       null: false
    t.json     "data",                   default: {}
    t.integer  "manually_created_by_id"
    t.integer  "sensor_id"
  end

  add_index "activities", ["manually_created_by_id"], name: "index_activities_on_manually_created_by_id", using: :btree
  add_index "activities", ["project_id"], name: "index_activities_on_project_id", using: :btree
  add_index "activities", ["sensor_id"], name: "index_activities_on_sensor_id", using: :btree

  create_table "application_settings", force: true do |t|
    t.boolean  "sensors_affect_project_status", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "countries", ["name"], name: "index_countries_on_name", unique: true, using: :btree

  create_table "email_subscriptions", force: true do |t|
    t.integer  "subscription_type", null: false
    t.integer  "account_id",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_subscriptions", ["account_id"], name: "index_email_subscriptions_on_account_id", using: :btree
  add_index "email_subscriptions", ["subscription_type", "account_id"], name: "index_email_subscriptions_on_subscription_type_and_account_id", unique: true, using: :btree

  create_table "gps_messages", force: true do |t|
    t.string   "esn"
    t.datetime "transmitted_at"
    t.string   "payload"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "message_type"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "confidence"
    t.integer  "vehicle_id"
  end

  add_index "gps_messages", ["vehicle_id"], name: "index_gps_messages_on_vehicle_id", using: :btree

  create_table "job_data", force: true do |t|
    t.json     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "partners", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "partners", ["name"], name: "index_partners_on_name", unique: true, using: :btree

  create_table "programs", force: true do |t|
    t.integer  "country_id", null: false
    t.integer  "partner_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "programs", ["country_id"], name: "index_programs_on_country_id", using: :btree
  add_index "programs", ["partner_id", "country_id"], name: "index_programs_on_partner_id_and_country_id", unique: true, using: :btree
  add_index "programs", ["partner_id"], name: "index_programs_on_partner_id", using: :btree

  create_table "projects", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "deployment_code",                            null: false
    t.integer  "wazi_id",                                    null: false
    t.integer  "grant_id"
    t.string   "quarter"
    t.string   "inventory_group"
    t.string   "community_name"
    t.string   "review_status_name"
    t.string   "package_id"
    t.string   "region"
    t.string   "possible_location_types"
    t.string   "inventory_type"
    t.string   "inventory_cost"
    t.string   "cost_actual"
    t.integer  "beneficiaries"
    t.string   "funding_source"
    t.string   "revenue_category"
    t.string   "revenue_category_display_label"
    t.string   "rehab"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "resubmission_notes"
    t.string   "location_type"
    t.string   "image_url"
    t.string   "plaque_text"
    t.string   "package_name"
    t.string   "grant_title"
    t.string   "grant_deployment_code"
    t.date     "completion_date"
    t.boolean  "is_ready_to_fund"
    t.integer  "status",                         default: 0, null: false
    t.integer  "program_id",                                 null: false
    t.string   "district"
    t.string   "site_name"
    t.string   "contact_name"
    t.string   "contact_email"
    t.string   "contact_phone_numbers",                                   array: true
    t.string   "state"
    t.string   "sub_district"
    t.string   "system_name"
    t.string   "water_point_name"
  end

  add_index "projects", ["deployment_code"], name: "index_projects_on_deployment_code", using: :btree
  add_index "projects", ["longitude", "latitude"], name: "index_projects_on_longitude_and_latitude", using: :btree
  add_index "projects", ["program_id"], name: "index_projects_on_program_id", using: :btree
  add_index "projects", ["status"], name: "index_projects_on_status", using: :btree
  add_index "projects", ["wazi_id"], name: "index_projects_on_wazi_id", unique: true, using: :btree

  create_table "sensor_registration_responses", force: true do |t|
    t.integer  "fs_survey_id",    null: false
    t.integer  "fs_response_id",  null: false
    t.json     "response",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "survey_type"
    t.datetime "submitted_at"
    t.string   "deployment_code"
    t.string   "error_code"
    t.string   "device_number"
  end

  add_index "sensor_registration_responses", ["survey_type"], name: "index_sensor_registration_responses_on_survey_type", using: :btree

  create_table "sensors", force: true do |t|
    t.string   "device_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "uptime"
    t.float    "daily_average_liters"
    t.integer  "days_for_daily_average_liters"
    t.string   "imei"
    t.boolean  "clock_fixed",                   default: false
    t.boolean  "storage_clock_fixed",           default: false
  end

  add_index "sensors", ["device_id"], name: "index_sensors_on_device_id", using: :btree
  add_index "sensors", ["project_id"], name: "index_sensors_on_project_id", using: :btree

  create_table "survey_responses", force: true do |t|
    t.integer  "fs_survey_id",   null: false
    t.integer  "fs_response_id", null: false
    t.datetime "submitted_at",   null: false
    t.integer  "project_id",     null: false
    t.json     "response",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "survey_type"
  end

  add_index "survey_responses", ["project_id"], name: "index_survey_responses_on_project_id", using: :btree
  add_index "survey_responses", ["survey_type"], name: "index_survey_responses_on_survey_type", using: :btree

  create_table "tickets", force: true do |t|
    t.integer  "status",                   null: false
    t.datetime "started_at",               null: false
    t.datetime "due_at"
    t.integer  "survey_response_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
    t.datetime "deleted_at"
    t.integer  "project_id",               null: false
    t.text     "notes"
    t.integer  "manually_created_by_id"
    t.integer  "manually_completed_by_id"
    t.integer  "weekly_log_id"
    t.string   "flowing_water_answer"
    t.string   "maintenance_visit_answer"
  end

  add_index "tickets", ["manually_completed_by_id"], name: "index_tickets_on_manually_completed_by_id", using: :btree
  add_index "tickets", ["manually_created_by_id"], name: "index_tickets_on_manually_created_by_id", using: :btree
  add_index "tickets", ["project_id"], name: "index_tickets_on_project_id", using: :btree
  add_index "tickets", ["survey_response_id"], name: "index_tickets_on_survey_response_id", using: :btree
  add_index "tickets", ["weekly_log_id"], name: "index_tickets_on_weekly_log_id", using: :btree

  create_table "vehicles", force: true do |t|
    t.string   "vehicle_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "esn",          null: false
    t.integer  "program_id"
  end

  add_index "vehicles", ["program_id"], name: "index_vehicles_on_program_id", using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "weekly_logs", force: true do |t|
    t.json     "data"
    t.integer  "sensor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "received_at"
    t.integer  "red_flag"
    t.integer  "unit_id"
    t.integer  "week"
    t.datetime "week_started_at"
  end

  add_index "weekly_logs", ["red_flag"], name: "index_weekly_logs_on_red_flag", order: {"red_flag"=>:desc}, using: :btree
  add_index "weekly_logs", ["sensor_id"], name: "index_weekly_logs_on_sensor_id", using: :btree

end
