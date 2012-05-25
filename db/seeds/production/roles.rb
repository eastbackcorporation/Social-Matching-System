# -*- coding: utf-8 -*-

#ロールの初期設定
roles=%W(admin sender receiver)
Role.delete_all
roles.each do |e|
  Role.create(:name => e)
end