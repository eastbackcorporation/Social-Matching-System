# -*- coding: utf-8 -*-

#送信者用コントローラ
class Sender::UsersController < ApplicationController
  before_filter :require_user
  before_filter :check_sender

  #作成したメーセッジのリスト
  def index
    #未実装
  end
end
