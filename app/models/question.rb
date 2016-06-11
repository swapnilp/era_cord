class Question < ActiveRecord::Base
  has_many :answers

  def as_json(options= {})
    options.merge({
                    id: id,
                    question: question
                  })
  end
end
