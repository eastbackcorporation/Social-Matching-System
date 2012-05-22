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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120522061005) do

  create_table "addresses", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.string   "prefecture",  :null => false
    t.string   "address1",    :null => false
    t.string   "address2",    :null => false
    t.string   "postal_code", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.boolean  "main",        :null => false
    t.string   "name"
  end

  create_table "categories", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "global_settings", :force => true do |t|
    t.float    "matching_range"
    t.float    "maximum_range"
    t.integer  "matching_interval",       :null => false
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.string   "name"
    t.float    "matching_step"
    t.text     "mail_template",           :null => false
    t.string   "mail_title_template",     :null => false
    t.integer  "matching_number_limit",   :null => false
    t.integer  "validated_time_interval", :null => false
  end

  create_table "massages", :force => true do |t|
    t.integer  "category_id"
    t.integer  "user_id"
    t.datetime "validated_datetime"
    t.datetime "active_datetime"
    t.string   "latitude"
    t.string   "longitude"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "address_id"
    t.integer  "matching_count"
    t.string   "matching_range"
    t.boolean  "active_flg",         :default => true
    t.integer  "matching_status_id",                    :null => false
    t.integer  "request_status_id",                     :null => false
    t.boolean  "end_flg",            :default => false
  end

  create_table "matching_statuses", :force => true do |t|
    t.string   "name",       :null => false
    t.boolean  "active_flg", :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "matching_users", :force => true do |t|
    t.integer  "massage_id",                    :null => false
    t.integer  "user_id",                       :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.float    "distance"
    t.boolean  "reject_flg", :default => false
  end

  create_table "receivers_locations", :force => true do |t|
    t.integer  "user_id"
    t.string   "latitude"
    t.string   "longitude"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "request_statuses", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "status_descriptions", :force => true do |t|
    t.integer  "request_status_id",  :null => false
    t.integer  "matching_status_id", :null => false
    t.text     "description"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "statuses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "active_flg", :null => false
  end

  add_index "statuses", ["name"], :name => "index_statuses_on_name", :unique => true

  create_table "users", :force => true do |t|
    t.string   "login",             :null => false
    t.string   "email",             :null => false
    t.string   "crypted_password",  :null => false
    t.string   "password_salt",     :null => false
    t.string   "persistence_token", :null => false
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "given_name"
    t.string   "family_name"
    t.string   "given_name_kana"
    t.string   "family_name_kana"
    t.string   "phone_number"
    t.string   "sex"
    t.date     "date_of_birth"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token", :unique => true

end
