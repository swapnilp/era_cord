class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    roles = user.roles.map(&:name)

    alias_action :create, :read, :update, :to => :create_update


    if roles.include? 'admin' || user.role == 'organisation'
      can :manage, :all
      #can :roll, :admin
      #can :roll, :clark
    elsif roles.include?('clark') || roles.include?('teacher')
      can :read, Gallery
      can :read, Event
      can :read, Album
      can :read, BatchResult
      can :read, Result
      
      can :roll, :clark
      can :read, Subject
      can :read, SubClass

      can :read, TimeTable
      can :calender_index, TimeTable
      can :get_time_table, Teacher if roles.include? 'verify_exam'
      
      can :organisation_cources, Organisation
      can :get_class_rooms, Organisation
      can :exams_graph_report, Organisation
      can :off_class_graph_report, Organisation
      can :absenty_graph_report, Organisation
      
      can :read, Exam
      can :calender_index, Exam
      can :get_filter_data, Exam
      can :get_catlogs, Exam
      can :get_descendants, Exam
      can :group_exam_report, Exam 
      can :update, Exam 
      can :destroy, Exam
      can :verify_exam, Exam if roles.include? 'verify_exam'
      can :exam_conducted, Exam if roles.include? 'exam_conduct'
      can :remove_absunt_student, Exam if roles.include? 'add_exam_absenty'
      can :add_absunt_student, Exam if roles.include? 'add_exam_absenty'
      can :ignore_student, Exam if roles.include? 'add_exam_absenty'
      can :remove_ignore_student, Exam if roles.include? 'add_exam_absenty'
      can :verify_exam_absenty, Exam if roles.include? 'verify_exam_absenty'
      can :add_exam_results, Exam if roles.include? 'add_exam_result'
      can :remove_exam_result, Exam if roles.include? 'add_exam_result'
      can :verify_exam_result, Exam if roles.include? 'verify_exam_result'
      can :publish_exam_result, Exam if roles.include? 'publish_exam'
      can :get_exam_info, JkciClass if roles.include? 'create_exam'
      can :get_exam_info, Exam if roles.include? 'create_exam'
      can :create, Exam if roles.include? 'create_exam'
      can :upload_paper, Exam if roles.include? 'create_exam'
      can :save_exam_points, Exam
      can :get_chapters_points, Exam
      can :manage_points, Exam
      
      can :read, JkciClass
      can :get_unassigned_classes, JkciClass
      can :students, JkciClass
      can :get_chapters, JkciClass
      can :filter_class_exams, JkciClass
      can :class_daily_teaches, JkciClass
      can :filter_daily_teach, JkciClass
      can :download_class_syllabus, JkciClass
      can :download_class_catlog, JkciClass
      can :download_class_student_list, JkciClass
      can :sub_organisation_class_report, JkciClass
      
      if roles.include? 'download_class_report'
        can :download_class_catlog, JkciClass
        can :download_class_student_list, JkciClass
        can :sub_organisation_class_report, JkciClass
      end
      
      can :filter_class, JkciClass
      can :get_notifications, JkciClass
      can :toggle_class_sms, JkciClass
      can :toggle_exam_sms, JkciClass
      can :presenty_catlog, JkciClass

      can :read, Notification
      
      can :read, DailyTeachingPoint
      can :get_catlogs, DailyTeachingPoint
      can :save_catlogs, DailyTeachingPoint
      can :get_dtp_info, JkciClass if roles.include? 'create_daily_teach'
      can :create, DailyTeachingPoint if roles.include? 'create_daily_teach'
      can :edit, DailyTeachingPoint if roles.include? 'create_daily_teach'
      can :add_absent_student, DailyTeachingPoint if roles.include? 'add_daily_teach_absenty'
      can :remove_absent_student, DailyTeachingPoint if roles.include? 'add_daily_teach_absenty'
      can :class_absent_verification, DailyTeachingPoint if roles.include? 'verify_daily_teach_absenty'
      
      can :read, Chapter
      can :get_points, Chapter
      #can :manage, Student

      
      can :read, Student
      can :enable_sms, Student 
      can :filter_students, Student 
      can :disable_student, Student 
      can :download_report, Student
      can :get_graph_data, Student
      can :get_filter_values, Student
      can :get_fee_info, Student if roles.include?('accountant')  || roles.include?('accountant_clark')
      can :paid_student_fee, Student if roles.include?('accountant')  || roles.include?('accountant_clark')
      can :get_payments_info, Student if roles.include? 'accountant' 
      can :manage, Contact
      can :print_receipt, StudentFee if roles.include?('accountant') || roles.include?('accountant_clark')
      can :new, Student if roles.include?('accountant') || roles.include?('accountant_clark')
      can :create, Student if roles.include?('accountant') || roles.include?('accountant_clark')

      can :read, SmsSent

      if roles.include? 'accountant'
        can :index, StudentFee
        can :filter_data, StudentFee
        can :graph_data, StudentFee
        can :print_account, StudentFee
        can :download_excel, StudentFee
      end      
    else
      can :read, Gallery
      can :read, Event
      can :read, Album
      can :read, BatchResult
      can :read, Result
      can :create, Organisation
      can :regenerate_organisation_code, Organisation      
      can :manage, Contact
      
    #  #can :read, User, id: user.id
    #  #can :read, Student, id: user.student_id.to_s.split(',').map(&:to_i)
    #  #can :read, Exam
    #  #can :create_update, ExamCatlog
    #  #can :create_update, ExamAbsent
    #  #can :create_update, ClassCatlog
    #  #can :read, Gallery
    #  #can :read, BatchResult
    #  #can :read, Result
    #  #can :read, Event
    #else
    #  can :read, :all
    #end
    ## Define abilities for the passed in user here. For example:
    ##
    ##   user ||= User.new # guest user (not logged in)
    ##   if user.admin?
    ##     can :manage, :all
    ##   else
    ##     can :read, :all
    ##   end
    ##
    ## The first argument to `can` is the action you are giving the user
    ## permission to do.
    ## If you pass :manage it will apply to every action. Other common actions
    ## here are :read, :create, :update and :destroy.
    ##
    ## The second argument is the resource the user can perform the action on.
    ## If you pass :all it will apply to every resource. Otherwise pass a Ruby
    ## class of the resource.
    ##
    ## The third argument is an optional hash of conditions to further filter the
    ## objects.
    ## For example, here the user can only update published articles.
    ##
    ##   can :update, Article, :published => true
    ##
    ## See the wiki for details:
    ## https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
    end
  end
end
