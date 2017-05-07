PublicActivity::Activity.class_eval do
  #attr_accessible :custom_field
  acts_as_organisation
  
  def as_json(options= {})
    options.merge({
                    id: id,
                    trackable_id: trackable_id,
                    trackable_type: trackable_type,
                    owner: owner.try(:email),
                    owner_type: owner_type,
                    key: key,
                    recipient: recipient.try(:name),
                    recipient_type: recipient_type,
                    created_at: created_at
                  })
  end
end


