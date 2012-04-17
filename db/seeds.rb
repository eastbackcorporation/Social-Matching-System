
#ロールの初期設定
role=%W(admin sender receiver)

Role.delete_all
role.each do |e|
  Role.create(:name => e)
end

#admin作成
admin = User.create(:login => "admin",
                          :email =>"sms@eastback.jp",
                          :password => "admin",
                          :password_confirmation => "admin")

admin.roles<<Role.admin