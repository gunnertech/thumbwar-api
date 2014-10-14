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

ActiveRecord::Schema.define(:version => 20141014034739) do

  create_table "alerts", :force => true do |t|
    t.integer  "alertable_id",                      :null => false
    t.string   "alertable_type",                    :null => false
    t.integer  "user_id",                           :null => false
    t.text     "body",                              :null => false
    t.boolean  "read",           :default => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "alerts", ["alertable_id", "alertable_type"], :name => "index_alerts_on_alertable_id_and_alertable_type"
  add_index "alerts", ["user_id"], :name => "index_alerts_on_user_id"

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id",   :default => 0
    t.string   "commentable_type"
    t.string   "title"
    t.text     "body"
    t.string   "subject"
    t.integer  "user_id",          :default => 0, :null => false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "followings", :force => true do |t|
    t.integer  "followee_id", :null => false
    t.integer  "follower_id", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "followings", ["followee_id"], :name => "index_followings_on_followee_id"
  add_index "followings", ["follower_id"], :name => "index_followings_on_follower_id"

  create_table "thumbwars", :force => true do |t|
    t.boolean  "accepted"
    t.integer  "challengee_id",                   :null => false
    t.integer  "challenger_id",                   :null => false
    t.text     "body",                            :null => false
    t.datetime "expires_at"
    t.boolean  "public",        :default => true
    t.string   "wager"
    t.integer  "winner_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "thumbwars", ["challengee_id"], :name => "index_thumbwars_on_challengee_id"
  add_index "thumbwars", ["challenger_id"], :name => "index_thumbwars_on_challenger_id"
  add_index "thumbwars", ["winner_id"], :name => "index_thumbwars_on_winner_id"

  create_table "users", :force => true do |t|
    t.string   "encrypted_password",     :default => "",   :null => false
    t.string   "facebook_token"
    t.string   "first_name"
    t.integer  "inviter_id"
    t.string   "last_name"
    t.string   "mobile",                                   :null => false
    t.boolean  "public",                 :default => true
    t.boolean  "publish_to_facebook"
    t.boolean  "publish_to_twitter"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean  "sms_notifications",      :default => true
    t.string   "token"
    t.string   "twitter_token"
    t.string   "username",               :default => "",   :null => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "users", ["inviter_id"], :name => "index_users_on_inviter_id"
  add_index "users", ["mobile"], :name => "index_users_on_mobile", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["token"], :name => "index_users_on_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username"

  create_table "watchings", :force => true do |t|
    t.integer  "thumbwar_id"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "watchings", ["thumbwar_id"], :name => "index_watchings_on_thumbwar_id"
  add_index "watchings", ["user_id"], :name => "index_watchings_on_user_id"

end
