  class MyRailtie < Rails::Railtie
    initializer :after_initialize do
        # ActiveRecord::Base.send(:include, Milia::Base)
        ActiveRecord::Base.send(:include, OrganisationHelper)        
    end
  end
