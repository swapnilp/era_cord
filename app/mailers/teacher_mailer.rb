class TeacherMailer < ActionMailer::Base
  default from: "admin@eracord.com"
  
  def registation_teacher(g_teacher)
    @g_teacher = g_teacher
    mail(to: @g_teacher.email, subject: 'Welcome to EraCord- Create eraCord teacher account')
  end
  
end

