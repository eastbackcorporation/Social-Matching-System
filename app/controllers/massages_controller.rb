# -*- coding: utf-8 -*-

#依頼情報用の共通部分コントローラ
class MassagesController < ApplicationController
  before_filter :check_all_reject

private
  #有効期限チェック
  def check_validated_datetime
    @massages = Massage.all
    @massages.each do |m|
      unless m.validated_datetime > DateTime.now || m.status.name=="完了" || m.status.name =="中止"
        #m.status=Status.where(:name=> "期限切れ").first
        m.status=Status.to("期限切れ").first
        m.save
      end
    end
  end

  #massageの状態チェック-before filter用
  def check_active
    @massages = Massage.all
    @massages.each do |m|
        m.active_flg=m.status.active_flg
        m.save
    end
  end

  #massageに紐付く全てのreceiverがrejectしているならばステータスを変更する
  def check_all_reject
    @massages = Massage.all
    @massages.each do |m|
      if  m.status.name=="マッチング終了" && self.all_receiver_reject(m)
        m.status=Status.to("該当者不受理").first
        m.save
        #TODO ここでsenderにメール送信
      end
    end
  end
protected
  #massageに紐付く全てのreceiverがrejectしているか?
  def all_receiver_reject(massage)
    @matching_users = MatchingUser.where(:massage_id=>massage.id)
    if @matching_users
      all_reject_flg=true
      @matching_users.each do |mu|
        unless mu.reject_flg
          all_reject_flg=false
        end
      end
      return all_reject_flg
    else
      false
    end
  end
end
