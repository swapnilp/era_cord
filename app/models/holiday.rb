class Holiday < ActiveRecord::Base
  belongs_to :organisation

  attr_accessor :isMultiDate, :dateRange, :allOrganisation, :classList

  scope :upcomming, -> { where("date >= ?", Date.today) }
  
  scope :current, -> { where("date >= ?", Date.new(Batch.active.first.year.to_i, 2))}
  
  default_scope { where("organisation_id in (?)", [0, Organisation.current_id].flatten.compact) }  

  
  def as_json(options= {})
    options.merge({
                    id: id,
                    date: date.strftime("%d %B %Y"),
                    reason: reason,
                    is_goverment: is_goverment
                  })
  end
end
