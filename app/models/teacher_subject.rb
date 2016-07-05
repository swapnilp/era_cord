class TeacherSubject < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :subject
  
  default_scope { where(organisation_id: Organisation.current_id) }  
  
  def as_json(options = {})
    options.merge({
                    id: id,
                    subject_name: subject.std_name
                  })
  end
end
