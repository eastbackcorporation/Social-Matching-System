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
      #jqGridでフィルターにかけるパラメータとして、id=># {ids}を設定する
      if ids != ""
        ids[-1,1] = ""
        params[:id] = ids
      else
        return
      end
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
    @validated_time_interval=GlobalSetting[:validated_time_interval]

    #マッチングを行う
    if self.matching
      @massage.update_attributes(:status_id=>2)#該当者あり
    end

    respond_to do |format|
      if @massage.save
        format.html { redirect_to(sender_massages_url) }
        #format.html { redirect_to [:sender,@massage] }
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

    #位置情報取得
    if @validated_time_interval>=0
      @receivers_locations=ReceiversLocation.all_at( DateTime.now-Rational( @validated_time_interval,24*60) )
    else
      @receivers_locations=ReceiversLocation.all
    end

    @matching_receivers=[]

    #最初のマッチング
    until self.search_user2(0,@range) || @range>=@maximum
      @range += @step
    end

    #再マッチング用スレッド
    #一定時間内に依頼が成立しなかった場合、範囲を広げて再びマッチングする
    t=Thread.new do
      begin
        self.repeat_matching{|a,b| self.search_user2(a,b) }
      rescue
        p "ERROR :.repeat_matching"
      end
    end

    if @matching_receivers.empty?
      Thread::kill(t)
      return false
    else
      Thread.new{self.send_mail(@matching_receivers)}
      return true
    end
  end

  #マッチングを繰り返す
  def repeat_matching(&search)
    msg_id=@massage.id

    #マッチングループ
    begin
      sleep @matching_interval #待ち時間

      @massage=Massage.find(msg_id)
      @matching_receivers=[]
      prev_range=@range
      @range+=@step

      until search.call(prev_range,@range) || @range>=@maximum
        @range += @step
      end

      #メール送信
      Thread.new{self.send_mail(@matching_receivers)}

      @massage.save
    end while @massage.active_flg && @range<@maximum #マッチング終了条件

    #終了処理
    @massage.status=Status.to("マッチング終了").first
    @massage.save
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

  #距離の近いreceiverの探索 ver2.1
  #TODO receiverが移動した時を考えるべき
  def search_user2(min_dis,max_dis)
    @used_receivers_id = @used_receivers_id || [] #matching済みのreveiver_id

    distance = {} # {user_id=>距離} を格納
    @receivers_locations.each do |rl|
      unless @used_receivers_id.index(rl.user_id)
        distance[rl.user_id] = self.distance(rl)
      end
    end

    matching_receiver_id, matching_receiver_dis= distance.min{ |a,b| a[1]<=>b[1] }

    if matching_receiver_dis && min_dis<matching_receiver_dis && matching_receiver_dis <=max_dis
      @matching_receivers << User.find(matching_receiver_id)
      @used_receivers_id << matching_receiver_id

      @massage.matching_range = matching_receiver_dis
      @massage.matching_count =  @massage.matching_count || 0
      @massage.matching_count += 1

      matching_user=MatchingUser.new(:massage_id=>@massage.id,
                                     :user_id=>matching_receiver_id.to_s,:distance=> matching_receiver_dis.to_s)
      matching_user.save
      return true
    else
      @massage.matching_count =  @massage.matching_count || 0
      @massage.matching_range = max_dis
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
      begin
       mail=MatchingMailer.matching_email(r,@massage)
       mail.transport_encoding = "8bit"
       mail.deliver
      rescue
        p "Not send mail"
      else
        p "mail send "+r.email
      end
    end
  end
end