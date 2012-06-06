# -*- coding: utf-8 -*-

#=== 依頼情報用の共通部分コントローラ
#主にbefore_filter用メソッドをここで定義している
class MassagesController < ApplicationController
  before_filter :check_all_reject
  before_filter :check_validated_datetime
  before_filter :check_end_datetime
  before_filter :check_active
  after_filter :check_active

private
  #応答有効期限チェック
  #有効期限を過ぎたmassageのmacthing_satatusを期限切れにする
  #-before filter用
  def check_validated_datetime
    @massages = Massage.all
    @massages.each do |m|
      if m.validated_datetime <= DateTime.now && m.matching_status.name=="検索終了"
        m.matching_status=MatchingStatus.to("期限切れ").first
        unless m.save
          logger.debug "ERROR : NOT save  check_validated_datetime"
        end
      end
    end
  end

  #終了チェック
  #実施日時(active_datetime)を過ぎたmassageには終了フラグ(end_flg)を立てる
  #また終了時にrequest_statusが受付中ならば、不成立にする
  #-before filter用
  def check_end_datetime
    @massages = Massage.all
    @massages.each do |m|
      if  m.active_datetime < DateTime.now
        m.update_attributes(:end_flg => true )
        if m.request_status.name == "受付中"
          m.update_attributes(:request_status_id=>RequestStatus.to("不成立").first.id)
        end
        unless m.save
          logger.debug "NOT save check_end_datetime"
        end
      end
    end
  end

  #massageの状態チェック
  #-before filter用
  def check_active
    @massages = Massage.all
    @massages.each do |m|
        if m.request_status.name == "成立" && m.matching_status.name == "検索中"
          m.matching_status = MatchingStatus.to("検索停止").first
        end
        if m.request_status.name == "受付中" && m.matching_status.name == "検索停止"
          m.matching_status = MatchingStatus.to("検索中").first
        end
        m.active_flg=m.matching_status.active_flg
        m.save
    end
  end

  #massageに紐付く全てのreceiverがrejectしているならばステータスを変更する
  #-before_filter用
  def check_all_reject
    @massages = Massage.all
    @massages.each do |m|
      if  m.matching_status.name=="検索終了" && self.all_receiver_reject(m)
        m.matching_status=MatchingStatus.to("該当者無し").first
        m.save
        #TODO ここでsenderにメール送信
      end
    end
  end

protected
  #massageに紐付く全てのreceiverがrejectしているか?
  #-check_all_reject用
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