class ChaptersPoint < ActiveRecord::Base
  belongs_to :chapter
  has_many :daily_teaching_point

  def as_json(options={})
    options.merge({
                    id: id,
                    name: name,
                    point_id: point_id
                  })
  end
end
