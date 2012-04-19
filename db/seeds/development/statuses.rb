# -*- coding: utf-8 -*-

#status 作成
statuses=%W(新規 完了 期限切れ)
statuses.each do |s|
  Status.create(:name =>s)
end