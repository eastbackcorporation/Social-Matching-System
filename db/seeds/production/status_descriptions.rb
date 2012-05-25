# -*- coding: utf-8 -*-

request_statuses=RequestStatus.all
matching_statuses=MatchingStatus.all

request_statuses.each do |rs|
  matching_statuses.each do |ms|
    StatusDescription.create(:request_status_id => rs.id,:matching_status_id => ms.id ,
                             :description=> rs.name + "かつ," + ms.name + "の詳細を表示する文章です" )

  end
end
