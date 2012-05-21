# -*- coding: utf-8 -*-

#status 作成
request_statuses=["受付中","成立","不成立","中止"]

request_statuses.each do |s|
  RequestStatus.create(:name =>s)
end