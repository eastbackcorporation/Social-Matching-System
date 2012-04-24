# -*- coding: utf-8 -*-

#ユーザ用モデル
#authlogicにより管理を提供
class User < ActiveRecord::Base
  attr_accessible :login, :password, :password_confirmation, :remember_me,:email,
                  :family_name, :given_name, :family_name_kana, :given_name_kana, :sex
  acts_as_authentic

  has_and_belongs_to_many :roles
  has_many :massages
  has_many :matching_users
  has_many :massages ,:through =>:matching_users
  ##pending
  #has_many :massages ,:through => :matching_users
  has_one :address
end
