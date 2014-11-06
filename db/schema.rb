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

ActiveRecord::Schema.define(version: 20141102211537) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alerts", force: true do |t|
    t.integer  "alertable_id",                   null: false
    t.string   "alertable_type",                 null: false
    t.integer  "user_id",                        null: false
    t.text     "body",                           null: false
    t.boolean  "read",           default: false
    t.boolean  "opened",         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "alerts", ["alertable_id", "alertable_type"], name: "index_alerts_on_alertable_id_and_alertable_type", using: :btree
  add_index "alerts", ["user_id"], name: "index_alerts_on_user_id", using: :btree

  create_table "challenges", force: true do |t|
    t.integer  "user_id",                           null: false
    t.integer  "thumbwar_id",                       null: false
    t.string   "status",        default: "pending", null: false
    t.string   "outcome"
    t.integer  "challenger_id",                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "challenges", ["challenger_id"], name: "index_challenges_on_challenger_id", using: :btree
  add_index "challenges", ["thumbwar_id"], name: "index_challenges_on_thumbwar_id", using: :btree
  add_index "challenges", ["user_id"], name: "index_challenges_on_user_id", using: :btree

  create_table "comments", force: true do |t|
    t.integer  "commentable_id",   default: 0
    t.string   "commentable_type"
    t.string   "title"
    t.text     "body"
    t.string   "subject"
    t.integer  "user_id",          default: 0, null: false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo"
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
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

  create_table "followings", force: true do |t|
    t.integer  "followee_id", null: false
    t.integer  "follower_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "followings", ["followee_id"], name: "index_followings_on_followee_id", using: :btree
  add_index "followings", ["follower_id"], name: "index_followings_on_follower_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "thumbwars", force: true do |t|
    t.integer  "challenger_id",                               null: false
    t.text     "body",                                        null: false
    t.datetime "expires_at"
    t.boolean  "public",              default: true
    t.string   "wager"
    t.string   "status",              default: "in_progress", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.string   "photo"
    t.boolean  "publish_to_twitter",  default: false
    t.boolean  "publish_to_facebook", default: false
  end

  add_index "thumbwars", ["challenger_id"], name: "index_thumbwars_on_challenger_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "encrypted_password",               default: "",   null: false
    t.string   "facebook_token"
    t.string   "first_name"
    t.integer  "inviter_id"
    t.string   "last_name"
    t.string   "mobile"
    t.boolean  "public",                           default: true
    t.boolean  "publish_to_facebook"
    t.boolean  "publish_to_twitter"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean  "sms_notifications",                default: true
    t.boolean  "email_notifications",              default: true
    t.string   "token"
    t.string   "twitter_token"
    t.string   "username",                         default: "",   null: false
    t.integer  "sign_in_count",                    default: 0,    null: false
    t.integer  "wins",                             default: 0,    null: false
    t.integer  "losses",                           default: 0,    null: false
    t.integer  "pushes",                           default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar"
    t.string   "verification_code"
    t.boolean  "verified",                         default: true
    t.string   "twitter_username"
    t.integer  "twitter_id",             limit: 8
    t.string   "twitter_secret"
    t.datetime "facebook_expires_at"
    t.string   "facebook_id"
    t.string   "email"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["facebook_id"], name: "index_users_on_facebook_id", using: :btree
  add_index "users", ["inviter_id"], name: "index_users_on_inviter_id", using: :btree
  add_index "users", ["mobile"], name: "index_users_on_mobile", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["token"], name: "index_users_on_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

  create_table "watchings", force: true do |t|
    t.integer  "thumbwar_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "watchings", ["thumbwar_id"], name: "index_watchings_on_thumbwar_id", using: :btree
  add_index "watchings", ["user_id"], name: "index_watchings_on_user_id", using: :btree

end
