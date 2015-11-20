class Event < ActiveRecord::Base


  belongs_to :master_event,   :class_name => "Event", :foreign_key => "master_event_id"#, :counter_cache => true
  has_many   :sub_events,    :class_name => "Event", :foreign_key => "master_event_id", :dependent => :destroy

  scope :master_events, -> { where("master_event_id is ?",  nil ).order("start_date DESC") }
  scope :remaining_events, -> { where("end_date >= ?",  Date.today ).order("start_date DESC") }
  scope :remaining_home_events, -> {where("end_date >= ? && is_public_event = ?",  Date.today, true).order("start_date DESC").limit(3) }
end
