# -*- coding: utf-8 -*-

#情報発信用コントローラ
class Sender::MassagesController < ApplicationController
  before_filter :require_user
  before_filter :check_sender

  #ユーザの発信した依頼情報一覧
  def index
    @massages=Massage.where(:user_id=>current_user.id)
  end

  #新規依頼作成ページ表示
  def new
    @massage = Massage.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @massage }
    end
  end

  #新規依頼作成
  def create
    @massage = Massage.new(params[:massage])
    @massage.update_attributes(:user_id=>current_user.id)
    @massage.update_attributes(:status_id=>1) #リファクタリングが必要
    respond_to do |format|
      if @massage.save
        self.matching
        format.html { redirect_to [:sender,@massage], notice: 'Massage was successfully created.' }
        format.json { render json: @massage, status: :created, location: @massage }
      else
        format.html { render action: "new" }
        format.json { render json: @massage.errors, status: :unprocessable_entity }
      end
    end
  end

 # 依頼情報の削除
  def destroy
    @massage = Massage.find(params[:id])
    @massage.destroy
    redirect_to(sender_massages_url, :notice => '情報を削除しました。')
  end

  #マッチングする
  #仮実装なので、位置情報に関連させてない
  def matching
    @receivers=Role.find(3).users.first
    @matching_user=MatchingUser.new(:massage_id=>@massage.id,:receiver_id=>@receivers.id)
    if @matching_user.save

    end
    #@receivers.each do |r|
    #  @matching_user=MatchingUser.new(:massage_id=>@massage.id,:receiver_id=>r.id)
    #  @matching_user.save
    #end
  end
end
