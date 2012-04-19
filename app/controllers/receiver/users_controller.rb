# -*- coding: utf-8 -*-

#受信者用コントローラ
class Receiver::UsersController < ApplicationController
  before_filter :require_user
  before_filter :check_receiver

  #受信したメーセッジのリスト
  def index
    @current_user=current_user
  end
end
