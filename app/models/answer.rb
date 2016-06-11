class Answer < ActiveRecord::Base
  belongs_to :question
  
  def as_json(options= {})
    options.merge({
                    id: id,
                    answer: answer
                  })
  end
end
