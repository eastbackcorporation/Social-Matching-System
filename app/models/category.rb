# -*- coding: utf-8 -*-

#依頼のカテゴリ用モデル
class Category < ActiveRecord::Base
  attr_accessible :name
  has_many :massages
end
