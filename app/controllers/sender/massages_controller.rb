# -*- coding: utf-8 -*-

include Math
#情報発信用コントローラ
class Sender::MassagesController < MassagesController
  before_filter :require_user
  before_filter :check_sender
  before_filter :check_validated_datetime

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
    @categories=Category.all
    @addresses=Address.where(:user_id=>current_user.id)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @massage }
    end
  end

  #新規依頼作成
  def create
    @massage = Massage.new(params[:massage])
    @massage.update_attributes(:user_id=>current_user.id)
    @massage.update_attributes(:status_id=>1)
    @massage.save
     #リファクタリングが必要
    if self.matching(300)
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

protected

  #マッチングする
  #仮実装なので、注意
  #lange は探索する緯度経度の範囲　
  def matching (lange)
    @receivers_locations=ReceiversLocation.all
    @matching_receivers=[]

    @receivers_locations.each do |rl|
      dis = self.distance(rl)
      if lange >=  dis
        #   問題あり
        @matching_user=MatchingUser.new(:massage_id=>@massage.id,:receiver_id=>rl.user_id)#,:distance=> dis.to_s)
        if @matching_user.save
          @matching_receivers<<rl.user
        end
      end
    end
    if @matching_receivers.empty?
       flash[:notice] = "該当者なし"
       return false
    else
      self.send_mail
      flash[:notice] = "該当者数 :" +  @matching_receivers.size.to_s + "人"
      return true
    end
  end

  #緯度経度-2点間の距離の計算
  def distance(location)
    earth_r=6378.137
    rad_dis_latitude=PI/180.0*(location.latitude.to_f- @massage.latitude.to_f )
    rad_dis_longitude=PI/180.0*(location.longitude.to_f- @massage.longitude.to_f )
    dis_latitude=earth_r*rad_dis_latitude
    dis_longitude=cos(PI/180.0*location.latitude.to_f)*earth_r*rad_dis_longitude
    return sqrt( dis_latitude*dis_latitude + dis_longitude*dis_longitude )
    #return sqrt( ( location.latitude.to_f- @massage.latitude.to_f )**2 + ( location.longitude.to_f - @massage.longitude.to_f )**2 )
  end

  #メール送信
  def send_mail
    @matching_receivers.each do |r|
      MatchingMailer.matching_email(r,@massage).deliver
    end
  end
end