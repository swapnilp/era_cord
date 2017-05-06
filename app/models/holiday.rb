class Holiday < ActiveRecord::Base

  acts_as_organisation(0)
  
  attr_accessor :isMultiDate, :dateRange, :allOrganisation, :classList

  scope :upcomming, -> { where("date >= ?", Date.today) }
  
  scope :current, -> { where("date >= ?", Date.new(Batch.active.first.year.to_i, 2))}
  
  def as_json(options= {})
    options.merge({
                    id: id,
                    date: date.strftime("%d %B %Y"),
                    reason: reason,
                    is_goverment: is_goverment
                  })
  end
end
