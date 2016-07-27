class TeacherMailer < ActionMailer::Base
  default from: "admin@eracord.com"
  
  def registation_teacher(g_teacher)
    @g_teacher = g_teacher
    mail(to: @g_teacher.email, subject: 'Welcome to EraCord- Create eraCord teacher account')
  end

  def add_teacher_mail(teacher)
    @teacher = teacher
    mail(to: @teacher.email, subject: 'Welcome to EraCord- Added to organisation as teacher')
  end

  def remove_teacher_mail(teacher)
    @teacher = teacher
    mail(to: @teacher.email, subject: 'Welcome to EraCord- Added to organisation as teacher')
  end
end

