class Chapter < ActiveRecord::Base
  belongs_to :subject
  has_many :chapters_points
  has_many :current_classes, class_name: "JkciClass", foreign_key: "current_chapter_id"

  def points_name
    self.chapters_points.map(&:name).join(",    ")
  end
end
