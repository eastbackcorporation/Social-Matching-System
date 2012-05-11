# -*- coding: utf-8 -*-

#情報発信用コントローラ
#マッチング処理はここで行う
class Sender::MassagesController < MassagesController
  include Math
  before_filter :require_user
  before_filter :check_sender
  before_filter :check_validated_datetime
  before_filter :check_active

  respond_to :html,:json

  #ユーザの発信した依頼情報一覧
  def index
    @massages=Massage.where(:user_id=>current_user.id)

    ids = ""

    @massages.each do |m|
      #PC画面(jqGrid)用
      ids << "^" << m.id.to_s << "$"
      ids << "|"
    end

    if mobile? then
      render :action => "index_mobile", :layout => 'mobile'
    else
      #jqGridでフィルターにかけるパラメータとして、id=>#{ids}を設定する
      #ids[-1,1] = ""
      params[:id] = ids
      respond_with() do |format|
        format.json {render :json => filter_on_params(Massage)}
      end
    end
  end

  #依頼情報詳細表示
  def show
   @massage=Massage.find(params[:id])
   if mobile? then
      render :action => "show_mobile", :layout => 'mobile'
   end
  end

  #新規依頼作成ページ表示
  def new
    @massage = Massage.new
    @categories=Category.all
    @addresses=Address.where(:user_id=>current_user.id)

    if mobile? then
      render :action => "new_mobile", :layout => 'mobile'
    end

    #respond_to do |format|
    #  format.html # new.html.erb
    #  format.json { render json: @massage }
    #end
  end

  #新規依頼作成
  def create
    @massage = Massage.new(params[:massage])
    @massage.update_attributes(:user_id=>current_user.id,:status_id=>1)
    @massage.save

    @range=GlobalSetting[:matching_range]
    @maximum=GlobalSetting[:maximum_range]
    @step=GlobalSetting[:matching_step]
    @matching_interval=GlobalSetting[:matching_interval]
    @matching_number_limit=GlobalSetting[:matching_number_limit]

    #if self.matching #マッチングを行う
    if self.matching2
      @massage.update_attributes(:status_id=>2)#該当者あり
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
  #マッチングを行う
  #一定時間内に依頼が成立しなかった場合、範囲を広げて再びマッチングする
  def matching
    @receivers_locations=ReceiversLocation.all
    @matching_receivers=[]


    #最初のマッチング
    until self.search_user(0,@range) || @range>=@maximum
      @range += @step
    end
    #再マッチング用スレッド
    #一定時間内に依頼が成立しなかった場合、範囲を広げて再びマッチングする
    t=Thread.new{ self.repeat_matching }

    if @matching_receivers.empty?
      Thread::kill(t)
      return false
    else
      Thread.new{self.send_mail(@matching_receivers)}
      return true
    end
  end

  #マッチングを繰り返す
  def repeat_matching
    msg_id=@massage.id
    begin
      sleep @matching_interval
      @massage=Massage.find(msg_id)
      @matching_receivers=[]
      prev_range=@range

      until self.search_user(prev_range,@range) || @range>=@maximum
        @range += @step
      end

      Thread.new{self.send_mail(@matching_receivers)}
      @massage.save
    end while @massage.active_flg && @range<@maximum
    @massage.status=Status.to("マッチング終了").first
  end

  #距離の近いreceiverの探索 ver1.0
  def search_user(min_dis,max_dis)
    rtn_flg=false

    @receivers_locations.each do |rl|
      dis = self.distance(rl)

      #範囲内かチェック
      if min_dis <= dis && dis <= max_dis
        @matching_user=MatchingUser.new(:massage_id=>@massage.id,:user_id=>rl.user_id,:distance=> dis.to_s)
        if @matching_user.save
          @matching_receivers<<rl.user
          rtn_flg=true
        end
      end
    end
    @massage.matching_count= @massage.matching_count || 0
    @massage.matching_count += @matching_receivers.size
    @massage.matching_range=max_dis
    return rtn_flg
  end

  #マッチングを行う ver2.0
  #一定時間内に依頼が成立しなかった場合、範囲を広げて再びマッチングする
  def matching2
    @receivers_locations = ReceiversLocation.all
    @matching_receivers = []

    #最初のマッチング
    until self.search_user2(0,@range) || @range>=@maximum
      @range += @step
    end

    t=Thread.new{ self.repeat_matching2 }

    if @matching_receivers.empty?
      Thread::kill(t)
      return false
    else
      Thread.new{self.send_mail(@matching_receivers)}
      return true
    end
  end

  #ver2.0版マッチングを繰り返す
  def repeat_matching2
    msg_id=@massage.id
    begin
      sleep @matching_interval
      @massage=Massage.find(msg_id)
      @matching_receivers=[]
      prev_range=@range

      until self.search_user2(prev_range,@range) || @range>@maximum
        @range += @step
      end

      self.send_mail(@matching_receivers)
      @massage.save
    end while @massage.active_flg && @range<@maximum
    @massage.status=Status.to("マッチング終了").first
  end

  #距離の近いreceiverの探索 ver1.0
  def search_user2(min_dis,max_dis)
    distance = {}
    @receivers_locations.each { |rl| distance[rl.user_id] = self.distance(rl) }
    @massage.matching_count =  @massage.matching_count || 0
    receivers = distance.sort{ |a,b| a[1]<=>b[1] }
    receiver = receivers[@massage.matching_count]

    if min_dis <= receiver[1] && receiver[1] <max_dis
      @matching_receivers << User.find(receiver[0])
      @range=receiver[1]
      @massage.matching_range = @range

      @massage.matching_count += 1

      matching_user=MatchingUser.new(:massage_id=>@massage.id,:user_id=>receiver[0].to_s,:distance=> receiver[1].to_s)
      matching_user.save
      return true
    else
      @massage.matching_range = @range
      return false
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
  end

  #メール送信
  def send_mail(receivers)
    receivers.each do |r|
      mail=MatchingMailer.matching_email(r,@massage)

      mail.transport_encoding = "8bit"
      if mail.deliver
        p "mail send "+r.email
      else
        raise ":Not send mail"
      end
    end
  end
end