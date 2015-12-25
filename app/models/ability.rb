class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new


    alias_action :create, :read, :update, :to => :create_update


    if user.has_role? :admin
      can :manage, :all
      #can :roll, :admin
      #can :roll, :clark
    elsif user.has_role? :clark
      can :read, Gallery
      can :read, Event
      can :read, Album
      can :read, BatchResult
      can :read, Result

      can :roll, :clark
      can :read, Subject
      can :read, SubClass
      can :read, JkciClass
      can :get_exam_info, JkciClass
      can :filter_class_exams, JkciClass
      can :class_daily_teaches, JkciClass
      can :filter_daily_teach, JkciClass
      can :download_class_catlog, JkciClass
      can :download_class_syllabus, JkciClass
      can :filter_class, JkciClass
      can :manage, DailyTeachingPoint
      can :manage, Exam
      can :manage, Chapter
      can :manage, Student
      can :enable_sms, Student 
      can :filter_students, Student 
      can :disable_student, Student 
      can :download_report, Student
    else
      can :read, Gallery
      can :read, Event
      can :read, Album
      can :read, BatchResult
      can :read, Result
      can :create, Organisation
      can :regenerate_organisation_code, Organisation      
      
      #can :roll, :clark
      #can :create_update, Chapter 
      #can :read, Event 
      #can :read, JkciClass 
      #can :read, Subject 
      #can :create_update, Exam 
      #can :read, Result 
      #can :read, Teacher 
      #can :read, Album 
      #can :create_update, ClassCatlog 
      #can :create_update, ExamAbsent 
      #can :read, Batch 
      #can :create_update, ExamCatlog 
      #can :read, ResultsPhoto 
      #can :create_update, ClassStudent 
      #can :manage, ExamResult 
      #can :read, BatchResult 
      #can :read, Gallery 
      ##can :manage, :sms_sent 
      #can :create_update, DailyTeachingPoint 
      #can :read, Student 
    #elsif user.parent?
    #  can :roll, :parent
    #  can :roll, :contact_us
    #  can :role, :timetable
    #  #can :read, Chapter 
    #  can :read, Event
    #  #can :read, JkciClass 
    #  #can :read, Subject 
    #  #can :read, Exam 
    #  can :read, Result 
    #  #can :read, Teacher 
    #  can :read, Album 
    #  #can :read, ClassCatlog 
    #  #can :read, ExamAbsent 
    #  #can :read, User 
    #  #can :read, Batch 
    #  #can :read, ExamCatlog 
    #  can :read, ResultsPhoto 
    #  #can :read, ClassStudent 
    #  #can :read, ExamResult 
    #  can :read, BatchResult 
    #  can :read, Gallery 
    #  #can :read, DailyTeachingPoint 
    #  #can :read, Student
    #  #can :read, :all
    #
    #
    #
    #
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
