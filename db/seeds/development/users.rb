# -*- coding: utf-8 -*-

#admin作成
admin = User.create(:login => "admin",
                          :email =>"sms@eastback.jp",
                          :password => "admin",
                          :password_confirmation => "admin")

admin.roles<<Role.admin

10.times do |r|
  login="test_teceiver"+r.to_s
  email=login+"@test.test"
  test_receiver = User.create(:login => login,
                          :email => email,
                          :password => "test",
                          :password_confirmation => "test")

  test_receiver.roles<<Role.receiver

end

test_sender = User.create(:login => "test_sender",
                          :email =>"test_sender@eastback.jp",
                          :password => "test",
                          :password_confirmation => "test")

test_sender.roles<<Role.sender

