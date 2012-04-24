# -*- coding: utf-8 -*-

#受信者(receiver)用コントローラ
class Receiver::UsersController < ApplicationController
  before_filter :require_user
  before_filter :check_receiver

  #receiverようhome画面
  def index
  end
end
