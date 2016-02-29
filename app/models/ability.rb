class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    roles = user.roles.map(&:name)

    alias_action :create, :read, :update, :to => :create_update


    if roles.include? 'admin'
      can :manage, :all
      #can :roll, :admin
      #can :roll, :clark
    elsif roles.include? 'clark'
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
      
      can :read, Exam
      can :calender_index, Exam
      can :get_filter_data, Exam
      can :get_catlogs, Exam
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
      
      can :read, JkciClass
      can :get_unassigned_classes, JkciClass
      can :students, JkciClass
      can :get_exam_info, JkciClass
      can :filter_class_exams, JkciClass
      can :class_daily_teaches, JkciClass
      can :filter_daily_teach, JkciClass
      can :download_class_catlog, JkciClass
      can :download_class_syllabus, JkciClass
      can :filter_class, JkciClass
      
      can :read, DailyTeachingPoint

      can :manage, Chapter
      #can :manage, Student
      can :read, Student
      can :enable_sms, Student 
      can :filter_students, Student 
      can :disable_student, Student 
      can :download_report, Student
      can :manage, Contact
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
