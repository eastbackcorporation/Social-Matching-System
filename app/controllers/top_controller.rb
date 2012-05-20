# -*- coding: utf-8 -*-

#=== ログイン後に最初の画面のコントローラ
class TopController < ApplicationController
  before_filter :require_user

  #各ロールごとのページに遷移する
  def index
    if current_user.roles.has(:admin)
      redirect_to admin_users_url
    elsif current_user.roles.has(:sender)
      redirect_to sender_massages_url
    elsif current_user.roles.has(:receiver)
      redirect_to receiver_massages_url
    end
  end
end
