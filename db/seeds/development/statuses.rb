# -*- coding: utf-8 -*-

#status 作成
statuses=%W(該当者なし 該当者あり 該当者不受理 完了 キャンセル 期限切れ)
statuses.each do |s|
  Status.create(:name =>s)
end