# -*- coding: utf-8 -*-

#admin作成
admin = User.create(:login => "admin",
                          :email =>"sms@eastback.jp",
                          :password => "admin",
                          :password_confirmation => "admin")

admin.roles<<Role.admin

3.times do |s|
  login="test_sender"+s.to_s
  email=login+"@test.test"
  test_sender = User.create(:login => login,
                          :email =>email,
                          :password => "test",
                          :password_confirmation => "test")

  test_sender.roles<<Role.sender
end

kou=User.create(:login => "kou_receiver",:email => "kou_honda@eastback.jp",
             :password => "test",:password_confirmation => "test")
kou.roles<<Role.receiver

9.times do |r|
  login="test_receiver"+r.to_s
  email="test#{r}@test.jp"
  test_receiver = User.create(:login => login,
                          :email => email,
                          :password => "test",
                          :password_confirmation => "test")

  test_receiver.roles<<Role.receiver
end
