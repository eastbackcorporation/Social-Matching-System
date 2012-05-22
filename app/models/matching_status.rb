# -*- coding: utf-8 -*-

#===マッチングステータスのためのモデルクラス
class MatchingStatus < ActiveRecord::Base
  attr_accessible :name,:active_flg
  has_many :massages
  has_many :request_status ,:through =>:status_description

  scope :to,lambda { |name| where(:name=>name) }
end
