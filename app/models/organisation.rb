class Organisation < ActiveRecord::Base

  has_ancestry

  belongs_to :master_organisation,   :class_name => "Organisation", :foreign_key => "parent_id"
  has_many   :sub_organisations,    :class_name => "Organisation", :foreign_key => "parent_id"#, :dependent => :destroy

  scope :master_organisations, lambda{ where(master_organisation: nil) }
  
  validates :email, presence: true, format: { with: /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/}
  #validates :email, uniqueness: { message: " allready registered. Please check email" }, if: Proc.new { |org| org.root? }
  validates :name, presence: true
  validates :mobile, presence: true, format: { with: /\d{10}/, message: "should be 10 digit"}

  after_create :generate_email_code

  has_many :class_catlogs
  has_many :class_students
  has_many :daily_teaching_points
  has_many :documents
  has_many :exams
  has_many :exam_absents
  has_many :exam_catlogs
  has_many :exam_points
  has_many :exam_results
  has_many :jkci_classes
  has_many :notifications
  has_many :parents_meetings
  has_many :sms_sents
  has_many :students
  has_many :student_subjects
  has_many :sub_classes
  has_many :teachers
  has_many :users
  has_many :organisation_standards
  has_many :standards,-> {uniq},  through: :organisation_standards
  has_many :time_tables
  has_many :time_table_classes
  has_many :off_classes
    

  cattr_accessor :current_id

  def generate_email_code
    e_code = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
    m_code = (0...7).map { ('a'..'z').to_a[rand(26)] }.join
    update_attributes({email_code: e_code, mobile_code: m_code})
    self.send_generated_code
    self.update_attributes({super_organisation_id: self.root_id})
  end

  def master_organisation?
    parent_id == nil
  end

  def add_standards(stds)
    stds.each do |std|
      self.standards << std
      jkci_class = self.jkci_classes.find_or_initialize_by({batch_id: Batch.last.id, standard_id: std.id})
      jkci_class.class_name = "#{std.std_name}-#{Batch.last.name}"
      jkci_class.is_current_active = true
      jkci_class.save
    end
  end

  def default_students
    Student.where("organisation_id = ? && last_present > ?", self.id, (Time.now - self.absent_days.days))
  end

  def default_students_count
    [self.name, self.default_students.count]
  end

  def subtree_performance_by_week
    sub_trees_performances =  self.subtree.map(&:organisation_performance_by_week)
    keys = sub_trees_performances.map(&:keys).flatten.uniq.map(&:to_date).sort.map{|date| date.strftime("%d %b %Y")}
    performances = []
    keys.each do |key|
      key_arr = [key]
      sub_trees_performances.each do |sub_trees_performance|
        key_arr << sub_trees_performance[key].to_i
      end
      performances << key_arr
    end
    return self.subtree.map(&:name), performances
  end

  def organisation_performance_by_week
    peroid_exams =  Exam.where(organisation_id: self.id).group_by_period(:week, :exam_date, format: "%d %b %Y", last: 10).count
    periods_catlog = DailyTeachingPoint.where(organisation_id: self.id).group_by_period(:week, :date, format: "%d %b %Y", last: 10).count
    
    week_performance= {}

    [peroid_exams, periods_catlog].map(&:keys).flatten.uniq.each do |week_date|
      week_performance[week_date] = peroid_exams[week_date].to_i + periods_catlog[week_date].to_i
    end
    week_performance
  end

  def organisation_seperate_performance_by_week
    peroid_exams =  Exam.where(organisation_id: self.id).group_by_period(:week, :exam_date, format: "%d %b %Y", last: 10).count
    periods_catlog = DailyTeachingPoint.where(organisation_id: self.id).group_by_period(:week, :date, format: "%d %b %Y", last: 10).count
    
    week_performance= []
    keys = [peroid_exams, periods_catlog].map(&:keys).flatten.uniq
    
    keys.each do |week_date| 
      week_performance << [week_date, peroid_exams[week_date].to_i, periods_catlog[week_date].to_i]
    end
    week_performance
  end

  def standards_performance_by_week
    standard_performances = self.standards.map do |standard|
      {standard.std_name => self.standard_performance_by_week(standard.id)}
    end
    keys = standard_performances.map(&:values).flatten.map(&:keys).flatten.uniq.map(&:to_date).sort.map{|date| date.strftime("%d %b %Y")}
    performances = []
    keys.each do |key|
      key_arr = [key]
      standard_performances.map(&:values).flatten.each do |sub_trees_performance|
        key_arr << sub_trees_performance[key].to_i
      end
      performances << key_arr
    end
    return standard_performances.map(&:keys).flatten, performances
  end

  def standard_performance_by_week(std_id)
    # Standard parformace to all subtree
    classes = JkciClass.where(standard_id: std_id, organisation_id: self.subtree.map(&:id))
    peroid_exams =  Exam.where(organisation_id: self.subtree.map(&:id), jkci_class_id: classes).group_by_period(:week, :exam_date, format: "%d %b %Y", last: 10).count
    periods_catlog = DailyTeachingPoint.where(organisation_id: self.subtree.map(&:id), jkci_class_id: classes).group_by_period(:week, :date, format: "%d %b %Y", last: 10).count
    keys = [peroid_exams, periods_catlog].map(&:keys).flatten.uniq
    performance = keys.map do |key| 
      {key =>  (peroid_exams[key].to_i + periods_catlog[key].to_i)}
    end.reduce(:merge)
    return performance || {}
  end

  def assigned_standards
    standards.where("organisation_standards.is_assigned_to_other is true")
  end
  
  def unassigned_standards
    standards.where("organisation_standards.is_assigned_to_other is false")
  end

  def sub_organisation_classes
    JkciClass.where(organisation_id: descendant_ids)
  end

  def standards_name
    #OrganisationStandard.where(organisation_id: self.id).map(&:standard).flatten.map(&:std_name).join(", ")
    std_names = []
    OrganisationStandard.where(organisation_id: self.id).each do |org_std|
      if org_std.is_assigned_to_other
        std_names << ["<span class='red'>#{org_std.standard.std_name}</span>"]
      else
        std_names << ["<span class='text-success'>#{org_std.standard.std_name}</span>"]
      end
    end
    std_names.join(", ").html_safe
  end

  def send_generated_code
    #org = Organisation.where(email: self.email).first
    if self.last_sent && ((self.last_sent + 5.hours) > Time.now)
    else
      self.update_attributes({last_sent: Time.now})
      Delayed::Job.enqueue OrganisationMailQueue.new(self)
      Delayed::Job.enqueue OrganisationRegistationSms.new(organisation_sms_message)
    end
  end

  def regenerate_organisation_code(mobile_number)
    m_code = (0...7).map { ('a'..'z').to_a[rand(26)] }.join
    update_attributes({mobile_code: m_code, mobile: mobile_number})
    Delayed::Job.enqueue OrganisationRegistationSms.new(organisation_sms_message)
  end

  def switch_organisation(old_organisation_id, new_organisation_id, standard_id)
    # pull back organisaiton standards classes from sub organisation to master organisation
    std = self.standards.where(id: standard_id).first
    if old_organisation_id == "0"
      old_organisation = self
      old_organisation_id = self.id
    else
      old_organisation = self.subtree.where(id: old_organisation_id).first
    end
    new_organisation = self.descendants.where(id: new_organisation_id).first

    if old_organisation.present? && new_organisation.present? && std.present? && !new_organisation.root?
      class_ids = JkciClass.where(standard_id: std.id, organisation_id: old_organisation_id).map(&:id)
      if class_ids.present?
        #ExamPoint.where(jkci_class_id: class_ids, organisation_id: old_organisation_id).update_all({organisation_id: new_organisation.id})
        Exam.where(jkci_class_id: class_ids, organisation_id: old_organisation_id).update_all({organisation_id: new_organisation.id})
        ExamCatlog.where(jkci_class_id: class_ids, organisation_id: old_organisation_id).update_all({organisation_id: new_organisation.id})
        DailyTeachingPoint.where(jkci_class_id: class_ids, organisation_id: old_organisation_id).update_all({organisation_id: new_organisation.id})
        ClassCatlog.where(jkci_class_id: class_ids, organisation_id: old_organisation_id).update_all({organisation_id: new_organisation.id})
        SubClass.where(jkci_class_id: class_ids, organisation_id: old_organisation_id).update_all({organisation_id: new_organisation.id})
        Student.where(standard_id: std.id, organisation_id: old_organisation_id).update_all({organisation_id: new_organisation.id})
        ClassStudent.where(jkci_class_id: class_ids, organisation_id: old_organisation_id).update_all({organisation_id: new_organisation.id})
        Notification.where(jkci_class_id: class_ids, organisation_id: old_organisation_id).update_all({organisation_id: new_organisation.id})
        JkciClass.where(standard_id: std.id, organisation_id: old_organisation_id).update_all({organisation_id: new_organisation.id})
        OrganisationStandard.unscoped.where(standard_id: std.id, organisation_id: old_organisation.path_ids).each do |org_standard|
          if org_standard.organisation.root?
            org_standard.update_attributes({is_assigned_to_other: true, assigned_organisation_id: new_organisation.id})
          else
            org_standard.destroy
          end
        end

        new_organisation.ancestor_ids.each do |ancestor_id|
          org = Organisation.where(id: ancestor_id).first
          if org && org.root?
            OrganisationStandard.unscoped.where(id: org.id, standard_id: std.id).update_all({is_assigned_to_other: true, assigned_organisation_id: new_organisation.id})
          elsif org
            org.organisation_standards.build({is_assigned_to_other: true, assigned_organisation_id: new_organisation.id, standard_id: std.id}).save
          end
        end
        new_organisation.standards << std
        return true
      else
        return false
      end
    else
      return false
    end
  end
  
  def pull_back_organisation(old_org)

    if old_org && !old_org.root?
      old_organisation_id = old_org.id
      old_org_standards_ids = OrganisationStandard.unscoped.where(organisation_id: old_organisation_id, is_assigned_to_other: false).map(&:standard_id)
      ExamPoint.where(organisation_id: old_organisation_id).update_all({organisation_id: self.id})
      Exam.where(organisation_id: old_organisation_id).update_all({organisation_id: self.id})
      ExamCatlog.where(organisation_id: old_organisation_id).update_all({organisation_id: self.id})
      DailyTeachingPoint.where(organisation_id: old_organisation_id).update_all({organisation_id: self.id})
      ClassCatlog.where(organisation_id: old_organisation_id).update_all({organisation_id: self.id})
      SubClass.where(organisation_id: old_organisation_id).update_all({organisation_id: self.id})
      StudentSubject.where(organisation_id: old_organisation_id).update_all({organisation_id: self.id})
      Student.where(organisation_id: old_organisation_id).update_all({organisation_id: self.id})
      ClassStudent.where(organisation_id: old_organisation_id).update_all({organisation_id: self.id})
      Notification.where(organisation_id: old_organisation_id).update_all({organisation_id: self.id})
      TimeTableClass.where(organisation_id: old_organisation_id).update_all({organisation_id: self.id})
      TimeTable.where(organisation_id: old_organisation_id).update_all({organisation_id: self.id})
      OffClass.where(organisation_id: old_organisation_id).update_all({organisation_id: self.id})
      JkciClass.where(organisation_id: old_organisation_id).update_all({organisation_id: self.id})
      
      unless self.root?
        OrganisationStandard.unscoped.where(standard_id: old_org_standards_ids, organisation_id: self.path_ids).update_all({is_assigned_to_other: true, assigned_organisation_id: self.id})
      end
      
      OrganisationStandard.unscoped.where(standard_id: old_org_standards_ids, organisation_id: self.id).update_all({is_assigned_to_other: false, assigned_organisation_id: nil})
      
      
      OrganisationStandard.unscoped.where(standard_id: old_org_standards_ids, organisation_id: self.subtree_ids).each do |org_standard|
        org_standard.destroy unless org_standard.organisation.root?
      end
      
      old_org.organisation_standards.destroy_all
      
      old_org.users.destroy_all
      if old_org.has_children?
        #.destroy
        old_org.children.update_all({parent_id: self.id})
        old_org.descendants.each do |old_org_desc|
          tree_ids = old_org_desc.ancestry.split('/')
          tree_ids.delete(old_org.id.to_s)
          old_org_desc.update_attributes(ancestry: tree_ids.join('/'))
        end
        old_org.destroy
      else
        old_org.destroy
      end
    end
    #old_org.sub_organisations.update_all({parent_id: self.id})
  end

  def launch_sub_organisation(new_sub_organisation_id, std)
    # assign standard to new organisation when launch sub organisation
    
    new_organisation = Organisation.where(id: new_sub_organisation_id).first
    transaction do
      if new_organisation
        self.organisation_standards.where(standard_id: std.id).first.update_attributes({is_assigned_to_other: true})
        new_organisation.standards << std rescue nil
        if std.jkci_classes.present?
          std_class_ids = std.jkci_classes.map(&:id)
          self.exam_points.joins(exam: :jkci_class).where("jkci_classes.id in (?)", std_class_ids).update_all({organisation_id: new_sub_organisation_id})
          self.exams.where("jkci_class_id in (?)", std_class_ids).update_all({organisation_id: new_sub_organisation_id})
          self.exam_catlogs.where("jkci_class_id in (?)", std_class_ids).update_all({organisation_id: new_sub_organisation_id})
          self.daily_teaching_points.where("jkci_class_id in (?)", std_class_ids).update_all({organisation_id: new_sub_organisation_id})
          self.class_catlogs.where("jkci_class_id in (?)", std_class_ids).update_all({organisation_id: new_sub_organisation_id})
          self.sub_classes.where("jkci_class_id in (?)", std_class_ids).update_all({organisation_id: new_sub_organisation_id})
          self.student_subjects.joins(student: :class_students).where("class_students.jkci_class_id in (?)", std_class_ids).update_all({organisation_id: new_sub_organisation_id})
          self.students.joins(:class_students).where("class_students.jkci_class_id in (?)", std_class_ids).update_all({organisation_id: new_sub_organisation_id})
          self.class_students.where("jkci_class_id in (?)", std_class_ids).update_all({organisation_id: new_sub_organisation_id})
          self.notifications.where("jkci_class_id in (?)", std_class_ids).update_all({organisation_id: new_sub_organisation_id})
          self.time_table_classes.joins(:time_table).where("time_tables.jkci_class_id in (?)", std_class_ids).update_all({organisation_id: new_sub_organisation_id})
          self.time_tables.where("jkci_class_id in (?)", std_class_ids).update_all({organisation_id: new_sub_organisation_id})
          self.off_classes.where("jkci_class_id in (?)", std_class_ids).update_all({organisation_id: new_sub_organisation_id})
          #std.jkci_classes.map(&:exams).flatten.map(&:exam_points).flatten.each{ |record| record.update_attributes({organisation_id: new_sub_organisation_id})}
          #std.jkci_classes.map(&:exams).flatten.each{ |record| record.update_attributes({organisation_id: new_sub_organisation_id}) }
          #std.jkci_classes.map(&:exam_catlogs).flatten.each{ |record| record.update_attributes({organisation_id: new_sub_organisation_id})}
          #std.jkci_classes.map(&:daily_teaching_points).flatten.each{ |record| record.update_attributes({organisation_id: new_sub_organisation_id})}
          #std.jkci_classes.map(&:class_catlogs).flatten.each{ |record| record.update_attributes({organisation_id: new_sub_organisation_id})}
          #std.jkci_classes.map(&:sub_classes).flatten.each{ |record| record.update_attributes({organisation_id: new_sub_organisation_id})}
          #std.jkci_classes.map(&:students).flatten.map(&:student_subjects).flatten.each{ |record| record.update_attributes({organisation_id: new_sub_organisation_id})}
          #std.jkci_classes.map(&:students).flatten.each{ |record| record.update_attributes({organisation_id: new_sub_organisation_id})}
          #std.jkci_classes.map(&:class_students).flatten.each{ |record| record.update_attributes({organisation_id: new_sub_organisation_id})}
          #std.jkci_classes.map(&:notifications).flatten.each{ |record| record.update_attributes({organisation_id: new_sub_organisation_id})}
        end
        OrganisationStandard.unscoped.where(standard_id: std.id, organisation_id: new_organisation.ancestor_ids)
          .update_all({assigned_organisation_id: new_sub_organisation_id})
        std.jkci_classes.update_all({organisation_id: new_sub_organisation_id})
      end
      save!
    end
  end

  
  def pull_back_standard(standard)
    old_organisation_id = OrganisationStandard.unscoped.where(standard_id: standard.id, organisation_id: self.subtree_ids, is_assigned_to_other: false).first.organisation_id
    self.pull_back_standard_to_parent_organisation(old_organisation_id, standard)
  end
  
  def pull_back_standard_to_parent_organisation(old_organisation_id, std)
    # pull back organisaiton standards classes from sub organisation to master organisation

    old_organisation = Organisation.where(id: old_organisation_id).first
    unless old_organisation.root?
      class_ids = JkciClass.where(standard_id: std.id, organisation_id: old_organisation_id).map(&:id)
      
      if class_ids.present?
        Exam.where(jkci_class_id: class_ids, organisation_id: old_organisation_id).update_all({organisation_id: self.id})
        ExamCatlog.where(jkci_class_id: class_ids, organisation_id: old_organisation_id).update_all({organisation_id: self.id})
        DailyTeachingPoint.where(jkci_class_id: class_ids, organisation_id: old_organisation_id).update_all({organisation_id: self.id})
        ClassCatlog.where(jkci_class_id: class_ids, organisation_id: old_organisation_id).update_all({organisation_id: self.id})
        SubClass.where(jkci_class_id: class_ids, organisation_id: old_organisation_id).update_all({organisation_id: self.id})
        Student.where(standard_id: std.id, organisation_id: old_organisation_id).update_all({organisation_id: self.id})
        ClassStudent.where(jkci_class_id: class_ids, organisation_id: old_organisation_id).update_all({organisation_id: self.id})
        Notification.where(jkci_class_id: class_ids, organisation_id: old_organisation_id).update_all({organisation_id: self.id})
        JkciClass.where(standard_id: std.id, organisation_id: old_organisation_id).update_all({organisation_id: self.id})
        OrganisationStandard.unscoped.where(standard_id: std.id, organisation_id: self.descendant_ids).each do |org_standard|
          org_standard.destroy unless org_standard.organisation.root?
        end
        self.organisation_standards.where(standard_id: std.id).update_all({is_assigned_to_other: false, assigned_organisation_id: nil})
      end
    end
  end

  def organisation_sms_message
    message = "One time password is #{self.mobile_code}  for #{self.name} registation on EraCord. Please do not share OTP to any one for securiety reason."
    url = "https://www.txtguru.in/imobile/api.php?username=#{SMSUNAME}&password=#{SMSUPASSWORD}&source=update&dmobile=91#{self.mobile}&message=#{message}"
    url_arry = [url, message, self.id, self.id]
  end

  def manage_standards(standard_ids)
    new_standards = Standard.select([:id, :name, :stream]).where("id in (?)", (standard_ids.split(',').map(&:to_i) + [0]))
    new_standards = new_standards.where("id not in (?)", (self.standards.map(&:id) + [0]) )
    new_standards.each do |std|
      self.standards << std
      self.create_class(std)
    end
  end

  def create_class(standard)
    batch = Batch.active.last
    if self.assigned_standards.include?(standard)
      jkci_class = self.jkci_classes.find_or_create_by({standard_id: standard.id, batch_id: batch.id, class_name: "#{standard.std_name}-#{batch.name}"})
      jkci_class.update_attributes({is_active: true})
    end
  end

end
