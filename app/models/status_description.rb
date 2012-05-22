# -*- coding: utf-8 -*-

#=== ステータス詳細のためのモデルクラス
#request_statusとmatching_statusの組み合わせによってステータス詳細を表示する
class StatusDescription < ActiveRecord::Base
  attr_accessible :request_status_id,:matching_status_id,:description

  belongs_to :request_status
  belongs_to :matching_status

  scope :status, lambda { |rs,ms| where( :request_status_id => RequestStatus.to(rs).first.id ,:matching_status_id => MatchingStatus.to(ms).first.id )}
end
