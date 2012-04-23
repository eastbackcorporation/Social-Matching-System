# -*- coding: utf-8 -*-

# 依頼情報のためのモデルクラス
class Massage < ActiveRecord::Base
  attr_accessible :category_id,:user_id,:active_datetime,:validated_datetime,
                  :latitude,:longitude,:status_id
  belongs_to :user
  belongs_to :category
  belongs_to :status
  has_many :matching_users, :dependent => :destroy
  has_many :user ,:through =>:matching_users

  validates :category_id ,:user_id,:status_id,:presence =>true

end
