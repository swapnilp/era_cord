class TeacherSubject < ActiveRecord::Base
  acts_as_organisation
  
  belongs_to :teacher
  belongs_to :subject
  
  
  def as_json(options = {})
    options.merge({
                    id: id,
                    name: subject.std_name
                  })
  end
end
