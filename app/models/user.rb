# -*- coding: utf-8 -*-

#ユーザ用モデル
#authlogicにより管理を提供
class User < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :login, :password, :password_confirmation, :remember_me,:email
  acts_as_authentic

  has_and_belongs_to_many :roles
end
