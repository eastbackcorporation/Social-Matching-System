# -*- coding: utf-8 -*-

#=== 依頼ステータスのためのモデルクラス
class RequestStatus < ActiveRecord::Base
  attr_accessible :name
  has_many :massages
  has_many :matching_status ,:through =>:status_description

  scope :to,lambda { |name| where(:name=>name) }
end
