# -*- coding: utf-8 -*-

#admin作成
admin = User.create(:login => "admin",
                          :email =>"sms@eastback.jp",
                          :password => "admin",
                          :password_confirmation => "admin")

admin.roles<<Role.admin

10.times do |r|
  login="test_receiver"+r.to_s
  email="kou_honda@eastback.jp"
  test_receiver = User.create(:login => login,
                          :email => email,
                          :password => "test",
                          :password_confirmation => "test")

  test_receiver.roles<<Role.receiver

end

3.times do |s|
  login="test_sender"+s.to_s
  email=login+"@test.test"
  test_sender = User.create(:login => login,
                          :email =>email,
                          :password => "test",
                          :password_confirmation => "test")

  test_sender.roles<<Role.sender
end

