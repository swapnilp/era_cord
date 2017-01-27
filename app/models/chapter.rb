class Chapter < ActiveRecord::Base
  belongs_to :subject
  has_many :chapters_points
  has_many :current_classes, class_name: "JkciClass", foreign_key: "current_chapter_id"

  def points_name(ids = [])
    if ids.blank?
      points_str = self.chapters_points.map(&:name)
      points_str = "#{points_str.join(", ")}"
    else
      points_str = self.chapters_points.collect {|p| ids.include?(p.id) ?  "<b>#{p.name}</b>" : p.name }
       points_str = "<em>#{points_str.join(", ")}</em>"
    end
    points_str
  end

  def as_json(options = {})
    options.merge({
                    id: id,
                    name: name,
                    chapt_no: chapt_no
                  })
  end
  
end
