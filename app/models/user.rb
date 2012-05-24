# -*- coding: utf-8 -*-

#ユーザ用モデル
#authlogicにより管理を提供
class User < ActiveRecord::Base
  attr_accessible :login, :password, :password_confirmation, :remember_me,:email,:phone_number,
                  :family_name, :given_name, :family_name_kana, :given_name_kana, :sex
  acts_as_authentic

  has_and_belongs_to_many :roles
  has_many :massages
  has_many :matching_users
  has_many :massages ,:through =>:matching_users
  ##pending
  #has_many :massages ,:through => :matching_users
  has_many :addresses
  has_one :receivers_location

  #accepts_nested_attributes_for :addresses, :allow_destroy => true
  attr_accessible :addresses

  #validates_format_of :family_name ,:with=> /^([一-龠]|[ぁ-ん]|[ァ-ヴ])*$/u
  #validates_format_of :given_name ,:with=> /^([一-龠]|[ぁ-ん]|[ァ-ヴ])*$/u
  #validates_format_of :family_name_kana,:with=>/[ァ-ヴ]*/u
  #validates_format_of :given_name_kana,:with=>/[ァ-ヴ]*/u
end
