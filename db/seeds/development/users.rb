# -*- coding: utf-8 -*-

#admin作成
admin = User.create(:login => "admin",
                          :email =>"sms@eastback.jp",
                          :password => "admin",
                          :password_confirmation => "admin")

admin.roles<<Role.admin

test_sender = User.create(:login => "test_sender",
                          :email =>"test_sender@eastback.jp",
                          :password => "test",
                          :password_confirmation => "test")

test_sender.roles<<Role.sender