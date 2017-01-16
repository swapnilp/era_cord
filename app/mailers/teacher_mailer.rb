class TeacherMailer < ActionMailer::Base
  default from: "admin@eracord.com"
  
  def registation_teacher(g_teacher)
    @g_teacher = g_teacher
    mail(to: @g_teacher.email, subject: 'Welcome to Eracord- Create Eracord teacher account')
  end

  def intimate_teacher(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to Eracord- Intimate Eracord teacher account')
  end

  def add_teacher_mail(teacher)
    @teacher = teacher
    mail(to: @teacher.email, subject: 'Welcome to Eracord- Added to organisation as teacher')
  end

  def remove_teacher_mail(teacher)
    @teacher = teacher
    mail(to: @teacher.email, subject: 'Welcome to Eracord- Removed Eracord teacher account')
  end
end

