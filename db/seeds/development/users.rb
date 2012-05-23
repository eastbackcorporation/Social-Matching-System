# -*- coding: utf-8 -*-

#admin作成
admin = User.create(:login => "admin",
                          :email =>"sms@eastback.jp",
                          :password => "admin",
                          :password_confirmation => "admin")

admin.roles<<Role.admin

3.times do |s|
  login="test_sender"+s.to_s
  email=login+"@example.com"
  test_sender = User.create(:login => login,
                          :email =>email,
                          :password => "test",
                          :password_confirmation => "test")
  test_sender.given_name="太郎"
  test_sender.family_name="田中"
  test_sender.sex="男"
  test_sender.phone_number="0900001"+s.to_s*4

  test_sender.roles<<Role.sender
  test_sender.save
end

10.times do |r|
  login="test_receiver"+r.to_s
  email="test#{r}@example.com"
  test_receiver = User.create(:login => login,
                          :email => email,
                          :password => "test",
                          :password_confirmation => "test")

  test_receiver.given_name="花子"
  test_receiver.family_name="鈴木"
  test_receiver.sex="女"
  test_receiver.phone_number="0900002"+r.to_s*4

  test_receiver.roles<<Role.receiver
  test_receiver.save
end
