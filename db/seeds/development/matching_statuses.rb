# -*- coding: utf-8 -*-

#status 作成
matching_statuses=[["検索中",true],
          ["検索終了",false],
          ["検索停止",false],
          ["該当者無し",false],
          ["期限切れ",false]]

matching_statuses.each do |s|
  MatchingStatus.create(:name =>s[0],:active_flg=>s[1])
end