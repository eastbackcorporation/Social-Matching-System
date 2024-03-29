# -*- coding: utf-8 -*-

#ユーザの種類(ロール)用モデル
class Role < ActiveRecord::Base
  attr_accessible :name
  has_and_belongs_to_many :users

  #保持しているRoleの確認
  def self.has(role_name)
    if self.where(:name =>role_name).first
      return true
    else
      return false
    end
  end

  # 管理者ロールを返す
  def self.admin
    return self.where(:name => "admin").first
  end

  # 送信者ロールを返す
  def self.sender
    return self.where(:name => "sender").first
  end

  # 受信者ロールを返す
  def self.receiver
    return self.where(:name => "receiver").first
  end
end
