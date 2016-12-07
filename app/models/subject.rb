class Subject < ActiveRecord::Base
  #attr_accessible :name

  has_many :jkci_classes
  has_many :chapters
  has_many :daily_teaching_points
  has_many :student_subjects
  has_many :students, through: :student_subjects
  belongs_to :standard

  scope :compulsory, -> { where(is_compulsory: true) }
  scope :optional, -> { where(is_compulsory: false) }
  
  def std_name
    "#{name}-#{standard.std_name}"
  end

  def only_std_name
    "#{name}-#{standard.name}"
  end


  def as_json(options= {})
    output = if options[:selected].present?
               options.merge({
                               id: self.id,
                               std_name: std_name,
                               name: name.capitalize,
                               ticked: options[:selected].include?(id)
                             })
             else
               options.merge({
                               id: self.id,
                               std_name: std_name,
                               name: name.capitalize,
                               color: color,
                               text_color: text_color
                             })
             end
    output.tap{|x| x.delete(:selected)} 
  end
end
