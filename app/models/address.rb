# -*- coding: utf-8 -*-

# 住所を管理するためのモデルクラス
class Address < ActiveRecord::Base
  attr_accessible :user_id, :prefecture,:address1,:address2,:postal_code,:main,:name
  #acts_as_authentic
  belongs_to :user
  has_one :massage

  validates_format_of :postal_code ,:with=> /^[0-9]{3}-[0-9]{4}$/,:massage => "郵便番号が正しくありません"
  validates_format_of :prefecture ,:with => /(都|道|府|県)$/,:massage =>"都道府県が正しくありません"
  validates_format_of :address1 ,:with => /(市|区|郡)/,:massage =>"都道府県が正しくありません"
end
