# -*- coding: utf-8 -*-

#status 作成
statuses=[["該当者なし",false],
          ["マッチング中",true],
          ["マッチング終了",false],
          ["該当者不受理",false],
          ["完了",false],
          ["中止",false],
          ["期限切れ",false]]

statuses.each do |s|
  Status.create(:name =>s[0],:active_flg=>s[1])
end