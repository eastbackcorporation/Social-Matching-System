# -*- coding: utf-8 -*-

#依頼情報確認用コントローラ
class Receiver::MassagesController < ApplicationController
  before_filter :require_user
  before_filter :check_receiver

  def index
    @massages=Massage.matching_users
    @massages=Massage.all
  end
end
