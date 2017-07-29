Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'dj.log'))
Delayed::Worker.logger.debug("Log Entry")

module Delayed
  module Plugins
    class Organisationwise < Plugin
      @prev_organisation = nil
      callbacks do |lifecycle|
        lifecycle.before(:invoke_job) do |job|
          @prev_organisation = Thread.current[:organisation_id]
          Organisation.set_current_organisation(job.organisation_id)
        end
        lifecycle.after(:invoke_job) do |job|
          Thread.current[:organisation_id] = @prev_organisation
        end
      end
    end
  end
end

Delayed::Worker.plugins << Delayed::Plugins::Organisationwise

Delayed::Job.class_eval do
  before_create :add_organisation

  def add_organisation
    self.organisation_id = Thread.current[:root_organisation_id] rescue nil
  end
end
