module OrganisationHelper

  def self.included(base)
    base.extend ClassMethods
  end
  module ClassMethods

    # ------------------------------------------------------------------------
    # acts_as_organisation -- makes a organisationed model
    # Forces all references to be limited to current_organisation rows
    # ------------------------------------------------------------------------
    def acts_as_organisation(default_id = nil)
      #attr_accessible :organisation_id
      belongs_to  :organisation
      validates_presence_of :organisation_id

      default_scope lambda { where( "#{table_name}.organisation_id in (?)", ([default_id] << Thread.current[:organisation_id]).flatten.compact ) }
      scope :current_org, -> { where( "#{table_name}.organisation_id in (?)", ([default_id] << Thread.current[:current_organisation_id]).flatten.compact)}
      # ..........................callback enforcers............................
      before_validation(:on => :create) do |obj|   # force organisation_id to be correct for current_user
        obj.organisation_id ||= Thread.current[:organisation_id]
        true  #  ok to proceed
      end

      # ..........................callback enforcers............................
      before_save do |obj|   # force organisation_id to be correct for current_user
        raise "Invalid Organisation Accesss on save" if !Thread.current[:organisation_id].to_a.include?(obj.organisation_id) && (File.basename($0) != "rake") && (obj.class.name != "User")
        true  #  ok to proceed
      end

      before_destroy do |obj|   # force organisation_id to be correct for current_user
        raise "Invalid Organisation Accesss on destroy" if !Thread.current[:organisation_id].to_a.include?(obj.organisation_id) && (File.basename($0) != "rake")
        true  #  ok to proceed
      end
    end

    def acts_as_universal()
      belongs_to  :organisation
      
      default_scope { where( "#{table_name}.organisation_id IS NULL" ) }
      # ..........................callback enforcers............................
      before_save do |obj|   # force organisation_id to be universal
        raise "Object with Organisation " unless obj.organisation_id.nil?
        true  #  ok to proceed
      end

      before_destroy do |obj|   # force organisation_id to be universal
        raise "Object with Organisation " unless obj.organisation_id.nil?
        true  #  ok to proceed
      end
    end
    

    # ------------------------------------------------------------------------
    # current_organisation -- returns organisation obj for current organisation
      # return nil if no current organisation defined
    # ------------------------------------------------------------------------
    def current_organisation()
      begin
        organisation = (
          Thread.current[:organisation_id].blank?  ?
          nil  :
          Organisation.find( Thread.current[:organisation_id] )
        )

        return organisation

      rescue ActiveRecord::RecordNotFound
        return nil
      end   
    end
  
    # ------------------------------------------------------------------------
    # current_organisation_id -- returns organisation_id for current organisation
    # ------------------------------------------------------------------------
    def current_organisation_id()
      return Thread.current[:organisation_id]
    end
  
    # ------------------------------------------------------------------------
    # set_current_organisation -- model-level ability to set the current organisation
    # NOTE: *USE WITH CAUTION* normally this should *NEVER* be done from
    # the models ... it's only useful and safe WHEN performed at the start
    # of a background job (DelayedJob#perform)
    # ------------------------------------------------------------------------
    def set_current_organisation( organisation )
      # able to handle organisation obj or organisation_id
      #case organisation
      #  when Organisation then organisation_id = organisation.id
      #  when Integer then organisation_id = organisation
      #  when Array then organisation_id = organisation
      #  else
      #    raise ArgumentError, "invalid organisation object or id"
      #end
      #old_id = ( Thread.current[:organisation_id].nil? ? '%' : Thread.current[:organisation_id] )
      if organisation.is_a? Integer
        organisation = Organisation.where(id: organisation).first
      end
      
      Thread.current[:organisation_id] = organisation.present? ? organisation.root.subtree.map(&:id) : nil
      Thread.current[:current_organisation_id] = organisation.present? ? organisation.subtree.map(&:id) : nil
      Thread.current[:root_organisation_id] = organisation.present? ? organisation.root.id : nil
      #organisation = Organisation.find(organisation_id) rescue nil
      #Time.zone = organisation.time_zone || 'Singapore' rescue 'Singapore'
    end
  
    # ------------------------------------------------------------------------
    # ------------------------------------------------------------------------
     
    # ------------------------------------------------------------------------
    # where_restrict_organisation -- gens organisation restrictive where clause for each klass
    # NOTE: subordinate join tables will not get the default scope by Rails
    # theoretically, the default scope on the master table alone should be sufficient
    # in restricting answers to the current_organisation alone .. HOWEVER, it doesn't feel
    # right. adding an additional .where( where_restrict_organisations(klass1, klass2,...))
    # for each of the subordinate models in the join seems like a nice safety issue.
    # ------------------------------------------------------------------------
    def where_restrict_organisation(*args)
      args.map{|klass| "#{klass.table_name}.organisation_id = #{Thread.current[:organisation_id]}"}.join(" AND ")
    end
  end
end  # module Base

ActiveRecord::Base.send(:include, OrganisationHelper)
