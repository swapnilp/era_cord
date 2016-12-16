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

ActiveRecord::Schema.define(version: 20161216175719) do

  create_table "albums", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.string   "location",    limit: 255
    t.date     "date"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "answers", force: :cascade do |t|
    t.integer  "question_id", limit: 4
    t.string   "answer",      limit: 255
    t.integer  "answer_id",   limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "attendances", force: :cascade do |t|
    t.integer  "student_id",      limit: 4, null: false
    t.integer  "organisation_id", limit: 4, null: false
    t.date     "date"
    t.time     "in_time"
    t.time     "out_time"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "batch_results", force: :cascade do |t|
    t.string   "batch",        limit: 255
    t.string   "description",  limit: 255
    t.string   "cover_img",    limit: 255
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "title",        limit: 255
    t.boolean  "is_published", limit: 1,   default: true
  end

  create_table "batches", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "std",        limit: 255
    t.string   "year",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active",  limit: 1,   default: true
  end

  create_table "chapters", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "subject_id", limit: 4
    t.integer  "chapt_no",   limit: 4
    t.integer  "std",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chapters_points", force: :cascade do |t|
    t.integer  "chapter_id", limit: 4
    t.string   "name",       limit: 255
    t.string   "weight",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "point_id",   limit: 255
  end

  create_table "class_catlogs", force: :cascade do |t|
    t.integer  "student_id",              limit: 4
    t.integer  "jkci_class_id",           limit: 4
    t.integer  "daily_teaching_point_id", limit: 4
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_present",              limit: 1
    t.boolean  "is_recover",              limit: 1, default: false
    t.date     "recover_date"
    t.boolean  "sms_sent",                limit: 1, default: false
    t.boolean  "is_followed",             limit: 1, default: false
    t.integer  "organisation_id",         limit: 4
  end

  create_table "class_students", force: :cascade do |t|
    t.integer  "jkci_class_id",         limit: 4
    t.integer  "student_id",            limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sub_class",             limit: 255, default: ",0,"
    t.integer  "organisation_id",       limit: 4
    t.integer  "roll_number",           limit: 4
    t.boolean  "is_duplicate",          limit: 1,   default: false
    t.string   "duplicate_field",       limit: 255
    t.boolean  "is_duplicate_accepted", limit: 1,   default: false
    t.float    "collected_fee",         limit: 24,  default: 0.0
    t.integer  "exam_catlogs_count",    limit: 4,   default: 0
    t.integer  "batch_id",              limit: 4
    t.float    "other_fee",             limit: 24,  default: 0.0
  end

  create_table "contacts", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "email",       limit: 255
    t.text     "mobile",      limit: 65535
    t.text     "reason",      limit: 65535
    t.text     "quote",       limit: 65535
    t.boolean  "is_followed", limit: 1,     default: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "daily_teaching_points", force: :cascade do |t|
    t.datetime "date"
    t.text     "points",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "jkci_class_id",       limit: 4
    t.integer  "teacher_id",          limit: 4
    t.boolean  "is_fill_catlog",      limit: 1,     default: false
    t.boolean  "is_sms_sent",         limit: 1,     default: false
    t.integer  "chapter_id",          limit: 4
    t.string   "chapters_point_id",   limit: 255
    t.string   "sub_classes",         limit: 255
    t.boolean  "verify_absenty",      limit: 1,     default: false
    t.integer  "organisation_id",     limit: 4
    t.integer  "subject_id",          limit: 4
    t.integer  "class_catlogs_count", limit: 4,     default: 0
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "documents", force: :cascade do |t|
    t.string   "document_file_name",    limit: 255
    t.string   "document_content_type", limit: 255
    t.integer  "document_file_size",    limit: 4
    t.datetime "document_updated_at"
    t.integer  "exam_id",               limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "organisation_id",       limit: 4
  end

  create_table "events", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.boolean  "is_single_day",   limit: 1,   default: true
    t.date     "start_date"
    t.date     "end_date"
    t.string   "time",            limit: 255
    t.string   "description",     limit: 255
    t.string   "location",        limit: 255
    t.string   "conductor",       limit: 255
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "master_event_id", limit: 4
    t.boolean  "is_public_event", limit: 1,   default: false
  end

  create_table "exam_absents", force: :cascade do |t|
    t.integer  "student_id",      limit: 4
    t.integer  "exam_id",         limit: 4
    t.boolean  "sms_sent",        limit: 1
    t.boolean  "email_sent",      limit: 1
    t.boolean  "reattend",        limit: 1
    t.datetime "attend_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organisation_id", limit: 4
  end

  create_table "exam_catlogs", force: :cascade do |t|
    t.integer  "exam_id",         limit: 4
    t.integer  "student_id",      limit: 4
    t.integer  "jkci_class_id",   limit: 4
    t.float    "marks",           limit: 24
    t.boolean  "is_present",      limit: 1
    t.boolean  "is_recover",      limit: 1,     default: false
    t.date     "recover_date"
    t.text     "remark",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_followed",     limit: 1,     default: false
    t.boolean  "absent_sms_sent", limit: 1,     default: false
    t.boolean  "is_ingored",      limit: 1
    t.integer  "rank",            limit: 4
    t.integer  "organisation_id", limit: 4
    t.float    "percentage",      limit: 24,    default: 0.0
  end

  create_table "exam_points", force: :cascade do |t|
    t.integer  "exam_id",           limit: 4
    t.integer  "chapters_point_id", limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "organisation_id",   limit: 4
  end

  create_table "exam_results", force: :cascade do |t|
    t.integer  "student_id",      limit: 4
    t.integer  "exam_id",         limit: 4
    t.float    "marks",           limit: 24
    t.boolean  "sms_sent",        limit: 1
    t.boolean  "email_sent",      limit: 1
    t.boolean  "late_attend",     limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organisation_id", limit: 4
  end

  create_table "exams", force: :cascade do |t|
    t.integer  "subject_id",            limit: 4
    t.string   "conducted_by",          limit: 255
    t.integer  "marks",                 limit: 4
    t.datetime "exam_date"
    t.float    "duration",              limit: 24
    t.string   "exam_type",             limit: 255
    t.integer  "std",                   limit: 4
    t.string   "remark",                limit: 255
    t.boolean  "is_result_decleared",   limit: 1
    t.boolean  "is_completed",          limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                  limit: 255
    t.boolean  "is_active",             limit: 1,   default: true
    t.integer  "jkci_class_id",         limit: 4
    t.string   "class_ids",             limit: 255
    t.string   "daily_teaching_points", limit: 255
    t.string   "sub_classes",           limit: 255
    t.boolean  "create_verification",   limit: 1,   default: false
    t.boolean  "verify_absenty",        limit: 1,   default: false
    t.boolean  "verify_result",         limit: 1,   default: false
    t.integer  "organisation_id",       limit: 4
    t.datetime "published_date"
    t.integer  "students_count",        limit: 4
    t.integer  "absents_count",         limit: 4
    t.integer  "parent_id",             limit: 4
    t.string   "ancestry",              limit: 255
    t.boolean  "is_group",              limit: 1,   default: false
    t.boolean  "is_point_added",        limit: 1,   default: false
  end

  create_table "feed_backs", force: :cascade do |t|
    t.string   "email",      limit: 255
    t.string   "title",      limit: 255
    t.text     "message",    limit: 65535
    t.string   "medium",     limit: 255,   default: "mobile", null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "g_teachers", force: :cascade do |t|
    t.string   "email",       limit: 255
    t.string   "first_name",  limit: 255
    t.string   "last_name",   limit: 255
    t.string   "mobile",      limit: 255
    t.string   "address",     limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "mobile_code", limit: 255
    t.string   "email_code",  limit: 255
    t.text     "photo",       limit: 65535
  end

  add_index "g_teachers", ["email"], name: "index_g_teachers_on_email", unique: true, using: :btree

  create_table "galleries", force: :cascade do |t|
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.float    "height",             limit: 24
    t.float    "width",              limit: 24
    t.datetime "image_updated_at"
    t.string   "location",           limit: 255
    t.string   "description",        limit: 255
    t.date     "event_date"
    t.integer  "album_id",           limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "hostel_logs", force: :cascade do |t|
    t.integer  "hostel_id",       limit: 4
    t.integer  "student_id",      limit: 4
    t.integer  "hostel_room_id",  limit: 4
    t.integer  "organisation_id", limit: 4
    t.string   "reason",          limit: 255
    t.string   "param",           limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "hostel_rooms", force: :cascade do |t|
    t.integer  "hostel_id",       limit: 4
    t.integer  "organisation_id", limit: 4
    t.string   "name",            limit: 255
    t.integer  "beds",            limit: 4
    t.integer  "extra_charges",   limit: 4
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "students_count",  limit: 4,   default: 0
  end

  create_table "hostel_transactions", force: :cascade do |t|
    t.integer  "hostel_id",       limit: 4
    t.integer  "hostel_room_id",  limit: 4
    t.integer  "student_id",      limit: 4
    t.integer  "organisation_id", limit: 4
    t.float    "amount",          limit: 24
    t.date     "date"
    t.boolean  "is_dues",         limit: 1,  default: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "pay_month",       limit: 4
  end

  create_table "hostels", force: :cascade do |t|
    t.integer  "organisation_id",   limit: 4
    t.string   "name",              limit: 255
    t.string   "gender",            limit: 255
    t.integer  "rooms",             limit: 4
    t.string   "owner",             limit: 255
    t.string   "address",           limit: 255
    t.float    "average_fee",       limit: 24
    t.integer  "student_occupancy", limit: 4
    t.boolean  "is_service_tax",    limit: 1
    t.float    "service_tax",       limit: 24
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "students_count",    limit: 4,   default: 0
    t.integer  "months",            limit: 4,   default: 1
    t.date     "start_date"
    t.integer  "start_month",       limit: 4,   default: 6, null: false
  end

  create_table "jkci_classes", force: :cascade do |t|
    t.string   "class_name",           limit: 255
    t.datetime "class_start_time"
    t.datetime "class_end_time"
    t.integer  "teacher_id",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "batch_id",             limit: 4
    t.boolean  "is_active",            limit: 1,   default: true
    t.integer  "subject_id",           limit: 4
    t.integer  "current_chapter_id",   limit: 4
    t.integer  "organisation_id",      limit: 4
    t.integer  "standard_id",          limit: 4
    t.boolean  "enable_class_sms",     limit: 1,   default: false
    t.boolean  "enable_exam_sms",      limit: 1,   default: false
    t.boolean  "has_sub_class",        limit: 1,   default: false
    t.boolean  "has_subject_assigned", limit: 1,   default: false
    t.boolean  "is_student_verified",  limit: 1,   default: false
    t.boolean  "is_current_active",    limit: 1,   default: false
    t.integer  "class_students_count", limit: 4,   default: 0
    t.integer  "notifications_count",  limit: 4,   default: 0
    t.float    "fee",                  limit: 24
  end

  create_table "logos", force: :cascade do |t|
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.float    "height",             limit: 24
    t.float    "width",              limit: 24
    t.datetime "image_updated_at"
    t.integer  "organisation_id",    limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "meetings_students", force: :cascade do |t|
    t.integer  "parents_meeting_id", limit: 4
    t.integer  "student_id",         limit: 4
    t.boolean  "sent_sms",           limit: 1,   default: false
    t.string   "mobile",             limit: 255
    t.integer  "organisation_id",    limit: 4
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.string   "message",              limit: 255
    t.string   "object_type",          limit: 255
    t.integer  "object_id",            limit: 4
    t.string   "url",                  limit: 255
    t.string   "comment",              limit: 255
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "actions",              limit: 255
    t.boolean  "is_completed",         limit: 1,   default: false
    t.boolean  "verification_require", limit: 1,   default: false
    t.integer  "organisation_id",      limit: 4
    t.integer  "jkci_class_id",        limit: 4
  end

  create_table "off_classes", force: :cascade do |t|
    t.integer  "jkci_class_id",   limit: 4
    t.integer  "sub_class_id",    limit: 4
    t.date     "date"
    t.integer  "subject_id",      limit: 4
    t.integer  "cwday",           limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "organisation_id", limit: 4
    t.integer  "teacher_id",      limit: 4
  end

  create_table "organisation_standards", force: :cascade do |t|
    t.integer  "organisation_id",          limit: 4
    t.integer  "standard_id",              limit: 4
    t.boolean  "is_active",                limit: 1,  default: true
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.boolean  "is_assigned_to_other",     limit: 1,  default: false
    t.integer  "assigned_organisation_id", limit: 4
    t.float    "total_fee",                limit: 24, default: 0.0
  end

  create_table "organisations", force: :cascade do |t|
    t.string   "name",                    limit: 255
    t.string   "email",                   limit: 255,                           null: false
    t.string   "mobile",                  limit: 255
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.string   "email_code",              limit: 255
    t.string   "mobile_code",             limit: 255
    t.datetime "last_sent"
    t.integer  "absent_days",             limit: 4,     default: 20
    t.integer  "parent_id",               limit: 4
    t.integer  "sub_organisations_count", limit: 4,     default: 0
    t.integer  "super_organisation_id",   limit: 4
    t.string   "ancestry",                limit: 255
    t.datetime "last_signed_in"
    t.boolean  "is_send_message",         limit: 1,     default: false
    t.string   "short_name",              limit: 255
    t.text     "account_sms",             limit: 65535
    t.string   "pan_number",              limit: 255
    t.string   "tan_number",              limit: 255
    t.float    "service_tax",             limit: 24,    default: 14.0
    t.boolean  "enable_service_tax",      limit: 1,     default: false
    t.string   "encrypted_password",      limit: 255,   default: "eracoed@123", null: false
    t.string   "reset_password_token",    limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           limit: 4,     default: 0,             null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",      limit: 255
    t.string   "last_sign_in_ip",         limit: 255
    t.string   "provider",                limit: 255
    t.string   "uid",                     limit: 255
    t.text     "tokens",                  limit: 65535
    t.datetime "token_expires_at"
    t.string   "logo_url",                limit: 255
  end

  add_index "organisations", ["ancestry"], name: "index_organisations_on_ancestry", using: :btree
  add_index "organisations", ["email"], name: "index_organisations_on_email", using: :btree
  add_index "organisations", ["reset_password_token"], name: "index_organisations_on_reset_password_token", unique: true, using: :btree

  create_table "parents_meetings", force: :cascade do |t|
    t.string   "agenda",          limit: 255
    t.datetime "date"
    t.string   "contact_person",  limit: 255
    t.integer  "batch_id",        limit: 4
    t.boolean  "sms_sent",        limit: 1,   default: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "organisation_id", limit: 4
    t.integer  "jkci_class_id",   limit: 4
  end

  create_table "payment_reasons", force: :cascade do |t|
    t.string   "reason",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "promotional_mails", force: :cascade do |t|
    t.string   "mails",      limit: 255
    t.string   "msg",        limit: 255
    t.string   "subject",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "questions", force: :cascade do |t|
    t.string   "email",      limit: 255
    t.string   "question",   limit: 255
    t.string   "is_admin",   limit: 255, default: "1"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "tag",        limit: 255
    t.string   "page",       limit: 255
  end

  create_table "removed_class_students", force: :cascade do |t|
    t.integer  "jkci_class_id",   limit: 4
    t.integer  "student_id",      limit: 4
    t.integer  "organisation_id", limit: 4
    t.float    "collected_fee",   limit: 24
    t.integer  "batch_id",        limit: 4
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.float    "other_fee",       limit: 24, default: 0.0
  end

  create_table "reset_passwords", force: :cascade do |t|
    t.string   "email",       limit: 255,                    null: false
    t.text     "token",       limit: 65535
    t.boolean  "send_token",  limit: 1,     default: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "object_type", limit: 255,   default: "User"
  end

  create_table "results", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "marks",            limit: 255
    t.string   "stream",           limit: 255
    t.string   "college",          limit: 255
    t.integer  "rank",             limit: 4
    t.string   "disp_rank",        limit: 255
    t.integer  "results_photo_id", limit: 4
    t.integer  "batch_id",         limit: 4
    t.integer  "student_id",       limit: 4
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "batch_result_id",  limit: 4
    t.string   "student_img",      limit: 255
    t.boolean  "is_published",     limit: 1,   default: true
  end

  create_table "results_photos", force: :cascade do |t|
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.float    "height",             limit: 24
    t.float    "width",              limit: 24
    t.datetime "image_updated_at"
    t.string   "location",           limit: 255
    t.string   "description",        limit: 255
    t.date     "event_date"
    t.integer  "result_id",          limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "resource_id",   limit: 4
    t.string   "resource_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "sms_sents", force: :cascade do |t|
    t.text     "number",          limit: 65535
    t.string   "obj_type",        limit: 255
    t.integer  "obj_id",          limit: 4
    t.text     "message",         limit: 65535
    t.boolean  "is_parent",       limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organisation_id", limit: 4
    t.integer  "student_id",      limit: 4
  end

  create_table "standards", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "stream",     limit: 255
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "is_active",  limit: 1,   default: true
    t.integer  "priority",   limit: 4
  end

  create_table "student_fees", force: :cascade do |t|
    t.integer  "student_id",        limit: 4
    t.integer  "jkci_class_id",     limit: 4
    t.integer  "batch_id",          limit: 4
    t.date     "date"
    t.float    "amount",            limit: 24
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "payment_type",      limit: 255, default: "cash"
    t.string   "bank_name",         limit: 255
    t.string   "cheque_number",     limit: 255
    t.string   "cheque_issue_date", limit: 255
    t.integer  "organisation_id",   limit: 4
    t.string   "book_number",       limit: 255
    t.string   "receipt_number",    limit: 255
    t.float    "service_tax",       limit: 24,  default: 0.0
    t.integer  "user_id",           limit: 4
    t.boolean  "is_fee",            limit: 1,   default: true
    t.integer  "payment_reason_id", limit: 4,   default: 1
  end

  create_table "student_photos", force: :cascade do |t|
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.float    "height",             limit: 24
    t.float    "width",              limit: 24
    t.datetime "image_updated_at"
    t.integer  "organisation_id",    limit: 4
    t.integer  "student_id",         limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "student_subjects", force: :cascade do |t|
    t.integer  "student_id",      limit: 4
    t.integer  "subject_id",      limit: 4
    t.integer  "batch_id",        limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "organisation_id", limit: 4
  end

  create_table "students", force: :cascade do |t|
    t.string   "first_name",        limit: 255
    t.string   "last_name",         limit: 255
    t.string   "email",             limit: 255
    t.string   "mobile",            limit: 255
    t.string   "parent_name",       limit: 255
    t.string   "p_mobile",          limit: 255
    t.string   "p_email",           limit: 255
    t.text     "address",           limit: 65535
    t.string   "group",             limit: 255
    t.string   "rank",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "std",               limit: 4
    t.boolean  "is_active",         limit: 1,     default: true
    t.string   "middle_name",       limit: 255
    t.integer  "batch_id",          limit: 4
    t.boolean  "enable_sms",        limit: 1,     default: false
    t.integer  "user_id",           limit: 4
    t.string   "gender",            limit: 255
    t.string   "initl",             limit: 255
    t.boolean  "is_disabled",       limit: 1,     default: false
    t.integer  "organisation_id",   limit: 4
    t.integer  "standard_id",       limit: 4
    t.datetime "last_present"
    t.string   "parent_occupation", limit: 255
    t.string   "adhar_card",        limit: 255
    t.integer  "hostel_id",         limit: 4
    t.integer  "hostel_room_id",    limit: 4
    t.float    "advances",          limit: 24,    default: 0.0
    t.date     "clearance"
  end

  create_table "sub_classes", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.integer  "jkci_class_id",   limit: 4
    t.string   "destription",     limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "organisation_id", limit: 4
  end

  create_table "subjects", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "standard_id",   limit: 4
    t.boolean  "is_compulsory", limit: 1,   default: true
    t.string   "color",         limit: 255
    t.string   "text_color",    limit: 255, default: "#FFF"
  end

  create_table "talent2015s", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "school_name",    limit: 255
    t.string   "medium",         limit: 255
    t.string   "parent_name",    limit: 255
    t.string   "p_occupation",   limit: 255
    t.string   "address",        limit: 255
    t.string   "contact_number", limit: 255
    t.string   "email",          limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "teacher_subjects", force: :cascade do |t|
    t.integer  "teacher_id",      limit: 4
    t.integer  "subject_id",      limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "organisation_id", limit: 4
  end

  create_table "teachers", force: :cascade do |t|
    t.string   "first_name",      limit: 255
    t.string   "last_name",       limit: 255
    t.string   "mobile",          limit: 255
    t.string   "email",           limit: 255
    t.text     "address",         limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organisation_id", limit: 4
    t.boolean  "is_full_time",    limit: 1,     default: true
    t.integer  "g_teacher_id",    limit: 4
    t.text     "photo",           limit: 65535
    t.boolean  "active",          limit: 1,     default: true
  end

  add_index "teachers", ["email"], name: "index_teachers_on_email", using: :btree

  create_table "temporary_organisations", force: :cascade do |t|
    t.string   "name",          limit: 255, default: "",    null: false
    t.string   "email",         limit: 255, default: "",    null: false
    t.string   "mobile",        limit: 255, default: "",    null: false
    t.string   "short_name",    limit: 255, default: ""
    t.string   "user_email",    limit: 255, default: ""
    t.string   "user_sms_code", limit: 255
    t.string   "id_hash",       limit: 255
    t.boolean  "is_confirmed",  limit: 1,   default: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "time_table_classes", force: :cascade do |t|
    t.integer  "organisation_id", limit: 4
    t.integer  "sub_class_id",    limit: 4
    t.integer  "time_table_id",   limit: 4
    t.boolean  "is_break",        limit: 1
    t.string   "slot_type",       limit: 255
    t.float    "start_time",      limit: 24
    t.float    "end_time",        limit: 24
    t.integer  "durations",       limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "cwday",           limit: 4
    t.integer  "subject_id",      limit: 4
    t.string   "class_room",      limit: 255
    t.integer  "teacher_id",      limit: 4
  end

  create_table "time_tables", force: :cascade do |t|
    t.string   "start_time",      limit: 255
    t.integer  "organisation_id", limit: 4
    t.integer  "jkci_class_id",   limit: 4
    t.integer  "sub_class_id",    limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "user_clerks", force: :cascade do |t|
    t.string   "email",           limit: 255,   null: false
    t.integer  "organisation_id", limit: 4
    t.text     "email_token",     limit: 65535
    t.text     "mobile_token",    limit: 65535
    t.text     "mobile",          limit: 65535, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255,   default: "",       null: false
    t.string   "encrypted_password",     limit: 255,   default: "",       null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0,        null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",                   limit: 255,   default: "parent"
    t.string   "student_id",             limit: 255
    t.string   "username",               limit: 255
    t.integer  "organisation_id",        limit: 4
    t.boolean  "is_enable",              limit: 1,     default: true
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.text     "tokens",                 limit: 65535
    t.datetime "token_expires_at"
    t.string   "mobile",                 limit: 255
    t.string   "device_id",              limit: 255
    t.integer  "mpin",                   limit: 4
    t.boolean  "verify_mobile",          limit: 1,     default: false
    t.string   "mobile_token",           limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "role_id", limit: 4
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end
