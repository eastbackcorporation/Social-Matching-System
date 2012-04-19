# -*- coding: utf-8 -*-

# 住所を管理するためのモデルクラス
class Address < ActiveRecord::Base
  attr_accessible :user_id, :prefecture,:address1,:address2,:postal_code
  #acts_as_authentic
  belongs_to :user
end
