class MatchingMailer < ActionMailer::Base
  default from: "from@example.com"

  def welcome_email(user)
    @user = user
    @url = "http://example.com/login"
    mail(:to => user.email,
         :subject => "Welcome to My Awesome Site")
  end

  def matching_email(receiver)
    @user = receiver
    @url = "http://example.com/login"
    mail(:to => receiver.email,
         :subject => "Yuur Matching")
  end
end
