namespace :offclass do

  desc "Calculate Off Class"
  task :calculate => :environment do
    Organisation.roots.each do |organisation|
      Organisation.current_id = organisation.subtree_ids
      TimeTable.joins(:jkci_class).where("jkci_classes.is_current_active = ?", true).each do |time_table|
	time_table.calculate_off_class(Date.yesterday)
      end
    end			    
  end
end     