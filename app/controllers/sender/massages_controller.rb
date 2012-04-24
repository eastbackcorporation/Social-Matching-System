# -*- coding: utf-8 -*-

include Math
#情報発信用コントローラ
class Sender::MassagesController < ApplicationController
  before_filter :require_user
  before_filter :check_sender

  #ユーザの発信した依頼情報一覧
  def index
    @massages=Massage.where(:user_id=>current_user.id)
  end

  #依頼情報詳細表示
  def show
   @massage=Massage.find(params[:id])
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
    @massage.update_attributes(:status_id=>0)
    @massage.save
     #リファクタリングが必要
    if self.matching(100)
      #リファクタリングが必要
      @massage.update_attributes(:status_id=>2)
    else
      @massage.update_attributes(:status_id=>1)
    end
    respond_to do |format|
      if @massage.save
        format.html { redirect_to [:sender,@massage] }
        format.json { render json: @massage, status: :created, location: @massage }
      else
        format.html { render :new}
        format.json { render json: @massage.errors, status: :unprocessable_entity }
      end
    end
  end

  #ステータスの変更
  def change_status
    @massage = Massage.find(params[:id])
    if @massage.update_attributes(:status_id=>params[:status])
      flash[:notice]="ステータス変更しました"
      redirect_to(sender_massages_url)
    else
      flash[:notice]="ステータス変更できませんでした"
      redirect_to(sender_massages_url)
    end
  end
  # 依頼情報の削除
  def destroy
    @massage = Massage.find(params[:id])
    @massage.destroy
    redirect_to(sender_massages_url, :notice => '情報を削除しました。')
  end

  #マッチングする
  #仮実装なので、注意
  #lange は探索する緯度経度の範囲　
  def matching (lange)
    @receivers_locations=ReceiversLocation.all
    @matching_users=[]

    @receivers_locations.each do |rl|
      dis = self.distance(rl)
      if lange >=  dis
        #   問題あり
        @matching_user=MatchingUser.new(:massage_id=>@massage.id,:receiver_id=>rl.user_id)#,:distance=> dis.to_s)
        if @matching_user.save
          #メール送信
          #MatchingMailer.matching_email(rl.user).deliver
          @matching_users<<@matching_user
        end
      end
    end
    if @matching_users.empty?
       flash[:notice] = "該当者なし"
       return false
    else
      flash[:notice] = "該当者数 :" +  @matching_users.size.to_s + "人"
      return true
    end
  end

  #2点間のユークリッド距離の計算
  def distance(location)
    return sqrt( ( location.latitude.to_f- @massage.latitude.to_f )**2 + ( location.longitude.to_f - @massage.longitude.to_f )**2 )
  end
end