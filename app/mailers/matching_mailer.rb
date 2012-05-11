# -*- coding: utf-8 -*-

#マッチング時に依頼情報を送信するためのメーラー
class MatchingMailer < ActionMailer::Base
  default from: "kou_honda@eastback.jp"

  #依頼情報の送信
  def matching_email(receiver,massage)

    @user = receiver
    @massage = massage

    @meta_data={"%sender.email%"=>massage.user.email,
                "%receiver.email%"=>receiver.email,
                "%receiver.login%"=>receiver.login,
                "%massage.category%"=>massage.category.name,
                "%massage_path%"=>receiver_massage_path(@massage)}

    @text =GlobalSetting[:mail_template]
    @meta_data.each do |key,value|
      @text=@text.gsub(Regexp.new(key),value)
    end
    @subject = GlobalSetting[:mail_title_template]
    @url = "http://example.com/login"
    #@email=receiver.email
    #dummy
    @email="receiver_sms@khn.sakura.ne.jp"
    mail(:to => @email,
         :subject => @suject)
  end
end
