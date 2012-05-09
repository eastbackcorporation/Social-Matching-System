# -*- coding: utf-8 -*-

class MatchingMailer < ActionMailer::Base
  default from: "kou_honda@eastback.jp"

  def welcome_email(user)
    @user = user
    @url = "http://example.com/login"
    mail(:to => user.email,
         :subject => "Welcome to My Awesome Site")
  end

  def matching_email(receiver,massage)
    @user = receiver
    @massage = massage

    @text = GlobalSetting[:mail_template]
    @subject = GlobalSetting[:mail_title_template]
    @url = "http://example.com/login"
    #@email=receiver.email
    #dummy
    @email="receiver_sms@khn.sakura.ne.jp"
    mail(:to => @email,
         :subject => @suject)
  end
end
