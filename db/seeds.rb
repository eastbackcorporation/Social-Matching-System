
#ロールの初期設定
role=%W(admin sender receiver)

role.each do |e|
  Role.create(:name => e)
end


