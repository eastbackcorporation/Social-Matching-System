# -*- coding: utf-8 -*-

# 依頼情報のためのモデルクラス
class Massage < ActiveRecord::Base
  attr_accessible :category_id,:user_id,:active_datetime,:validated_datetime,
                  :latitude,:longitude,:address_id,:matching_count,:matching_range,
                  :active_flg,:matching_status_id,:request_status_id,:end_flg,:description
  belongs_to :user
  belongs_to :category
  belongs_to :matching_status
  belongs_to :request_status
  belongs_to :address
  has_many :matching_users, :dependent => :destroy
  has_many :users ,:through =>:matching_users

  validates :category_id ,:user_id,:address_id,:latitude,:longitude,:presence =>true

  #現在時刻より前は拒否する
  validates_each :active_datetime,:validated_datetime do |record, attr, value|
    if value < DateTime.now
      record.errors.add attr, "を現在時刻より後に設定してください"
    end
  end
end
