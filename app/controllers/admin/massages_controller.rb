# -*- coding: utf-8 -*-

#マッチング(依頼情報)管理用コントローラ
#admin のみが情緒の管理が行える
class Admin::MassagesController < ApplicationController
  #依頼情報一覧表示
  def index
    @massages=Massage.all
  end

  #依頼情報の詳細
  def show
    @massage=Massage.find(params[:id])
    @matching_users=@massage.users
  end
end
