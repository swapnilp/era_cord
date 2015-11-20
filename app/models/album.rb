class Album < ActiveRecord::Base
  has_many :galleries


  def cover_image
    galleries.sample.image.url(:hunt_img) rescue ''
  end
end
