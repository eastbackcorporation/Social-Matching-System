# -*- coding: utf-8 -*-

#依頼情報確認用コントローラ
class Receiver::MassagesController < ApplicationController
  before_filter :require_user
  before_filter :check_receiver

  #自分宛の依頼情報一覧
  def index
    @matching_users=MatchingUser.where(:receiver_id=>current_user.id)
    @massages=[]
    @matching_users.each do |mu|
      @massages<<mu.massage
    end
  end

  #詳細表示
  def show
    @massage=Massage.find(params[:id])
  end

  #依頼拒否用アクション
  def reject
    @matching_user=MatchingUser.where(:massage_id=>params[:id],:receiver_id=>current_user.id).first
    @matching_user.update_attributes(:reject_flg=>true)

    @matching_users=MatchingUser.where(:massage_id=>params[:id])

    all_reject_flg=true
    @matching_users.each do |m|
      unless m.reject_flg
        all_reject_flg=false
      end
    end
    if all_reject_flg
      @massage=Massage.find(params[:id])
      @massage.update_attributes(:status_id=>3)#status_id 3: 該当者不受理
    end
    redirect_to(receiver_users_path, :notice => "お断りしました")
  end
end
