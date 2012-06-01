# -*- coding: utf-8 -*-

#===情報発信用コントローラ
#マッチング処理はここで行う
class Sender::MassagesController < MassagesController
  include Math
  before_filter :require_user
  before_filter "check_role(:role=>:sender)".to_sym
  before_filter :get_global_setting,:only => :create

  respond_to :html,:json

  # ユーザの発信した依頼情報一覧
  #実施前の依頼のみ表示
  def index
    @massages=Massage.where(:user_id=>current_user.id,:end_flg=>false)

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
    @massage.user=current_user
    @massage.attributes = params[:massage] if request.post?
    if mobile? then
      render :action => "new_mobile", :layout => 'mobile'
    end
  end

  #新規依頼'確認'ページ表示
  def confirm
    @massage = Massage.new(params[:massage])
    @massage.user=current_user

    #TODO
    #ここでは、有効期限と実施日の順序関係をvalidateしている。
    #可能な限りモデル側に実装すべきである
    if  @massage.active_datetime < @massage.validated_datetime
        @categories=Category.all
        @addresses=Address.where(:user_id=>current_user.id)
        flash[:notice] =  "有効期限より実施日後にすることはできません"
        render :action => :new
    elsif @massage.valid?
      render :action => 'confirm'
    else
      render :action => 'new'
    end
  end

  #新規依頼作成
  def create
    @massage = Massage.new(params[:massage])
    @massage.user=current_user
    @massage.matching_status=MatchingStatus.to("検索中").first
    @massage.request_status=RequestStatus.to("受付中").first

    if @massage.save
      #マッチングを行う
      self.matching_users
    end

    respond_to do |format|
      if @massage.save
        if mobile? then
          format.html { redirect_to(sender_massages_url) }
          format.json { render json: @massage, status: :created, location: @massage }
        end
        flash[:notice]="依頼を登録しました！"
        format.html { redirect_to [:sender,@massage] }
        format.json { render json: @massage, status: :created, location: @massage }
      else
        @categories=Category.all
        @addresses=Address.where(:user_id=>current_user.id)
        flash[:notice]="依頼の登録に失敗しました！"
        format.html { render :new  }
        format.json { render json: @massage.errors, status: :unprocessable_entity }
      end
    end
  end

  #ステータスの変更
  def change_status
    @massage = Massage.find(params[:id])
    unless @massage.end_flg
      if @massage.update_attributes(:request_status_id=>params[:request_status])
        flash[:notice]="ステータス変更しました"
        redirect_to(sender_massage_url)
      else
        flash[:notice]="ステータス変更できませんでした"
        redirect_to(sender_massage_url)
      end
    else
       flash[:notice]="終了しているメッセージです"
       redirect_to(sender_massage_url)
    end
  end

  # 依頼情報の削除
  def destroy
    @massage = Massage.find(params[:id])
    @massage.destroy
    redirect_to(sender_massages_url, :notice => '情報を削除しました。')
  end

protected
  #グローバルセッテイングの情報参照
  def get_global_setting
    @range=GlobalSetting[:matching_range]
    @maximum=GlobalSetting[:maximum_range]
    @step=GlobalSetting[:matching_step]
    @matching_interval=GlobalSetting[:matching_interval]
    @matching_number_limit=GlobalSetting[:matching_number_limit]
    @validated_time_interval=GlobalSetting[:validated_time_interval]
  end

  #位置情報取得
  def get_receivers_locations
    #更新日時が@validated_time_interval以内のもののみ取得
    #ただし、@validated_time_intervalが負の時はすべて取得
    if @validated_time_interval>=0
      return ReceiversLocation.all_at( DateTime.now-Rational( @validated_time_interval,24*60) )
    else
      return ReceiversLocation.all
    end
  end

  #マッチングを行う
  #一定時間内に依頼が成立しなかった場合、範囲を広げて再びマッチングする
  def matching_users

    @matching_receivers=[]
    #最初のマッチング
    #成功するまでrangeを広げる
    self.search_users(0,@range)

    #再マッチング用スレッド
    #一定時間内に依頼が成立しなかった場合、範囲を広げて再びマッチングする
    t=Thread.new do
      begin
        self.repeat_matching{|a,b| self.search_users(a,b) }
      rescue
        p "ERROR :.repeat_matching"
      end
    end

    if @matching_receivers.empty?
      return false
    else
      Thread.new{self.send_mail(@matching_receivers)}
      return true
    end
  end

  #マッチングを繰り返す
  #一定時間内に依頼が成立しなかった場合、範囲を広げて再びマッチングする
  # search.call を用いいてマッチング
  def repeat_matching(&search)
    @current_massage_id=@massage.id

    sleep @matching_interval #最初の待ち時間
    @massage=Massage.find(@current_massage_id)

    #マッチング ループ
    while @massage.active_flg && @range<@maximum #終了条件

      @massage=Massage.find(@current_massage_id)
      @matching_receivers=[]
      min_distance,max_distance=@range,@range+@step

      #receiverの探索
      search.call(min_distance,max_distance)  #  => @matching_receivers << result

      #メール送信
      Thread.new{self.send_mail(@matching_receivers)}
      @massage.save

      sleep @matching_interval #待ち時間

      @massage=Massage.find(@current_massage_id)
      #一時的なストップ
      #
      while @massage.matching_status.name == "検索停止"  &&   !@massage.end_flg do

        sleep 5
        @massage=Massage.find(@current_massage_id)
      end
    end

    #終了処理
    @massage.matching_status=MatchingStatus.to("検索終了").first
    @massage.save
  end

  #receiverの探索
  #見つかるまで、範囲を広げる
  def search_users(min_distance,max_distance)
    #成功するまでrangeを広げる
    until self.search_user2(min_distance,max_distance) || max_distance>=@maximum
      max_distance += @step
      @range = max_distance
     end
  end

  #距離の近いreceiverの探索 ver1.0
  def search_user(min_distance,max_distance)
    rtn_flg=false
    #位置情報取得
    @receivers_locations=self.get_receivers_locations
    @receivers_locations.each do |receivers_location|
      distance = self.measure_distance(receivers_location)

      #範囲内かチェック
      if min_distance <= distance && distance <= max_distance
        rtn_flg=self.save_matching_user(receivers_location.id,distance)
      end
    end
    @massage.matching_range=max_distance
    return rtn_flg
  end

  #距離の近いreceiverの探索 ver2.1
  def search_user2(min_distance,max_distance)
    #位置情報取得
    @receivers_locations=self.get_receivers_locations

    #matching済みのreveiver_id
    @used_receivers_id = @used_receivers_id || []

    # {user_id=>距離} を格納
    distance = {}
    @receivers_locations.each do |receivers_location|
      unless @used_receivers_id.index(receivers_location.user_id)
        distance[receivers_location.user_id] = self.measure_distance(receivers_location)
      end
    end

    # 距離が最小のreveiverにマッチする
    matching_receiver_id, matching_receiver_distance= distance.min{ |a,b| a[1]<=>b[1] }

    #範囲条件の確認
    if matching_receiver_distance && matching_receiver_distance <= max_distance
      #マッチングしたユーザをする保存する
      return self.save_matching_user(matching_receiver_id,matching_receiver_distance)
    else
      @massage.matching_count =  @massage.matching_count || 0
      @massage.matching_range = max_distance
      return false
    end
  end

  #マッチングしたユーザの保存
  def save_matching_user(matching_user_id,matching_user_dis)
      @matching_receivers << User.find(matching_user_id)
      @used_receivers_id << matching_user_id

      @massage.matching_range = matching_user_dis
      @massage.matching_count =  @massage.matching_count || 0
      @massage.matching_count += 1

      matching_user=MatchingUser.new(:massage_id=>@massage.id,
                                     :user_id=>matching_user_id.to_s,:distance=> matching_user_dis.to_s)
      return matching_user.save
  end

  #緯度経度-2点間の距離の計算
  def measure_distance(location)
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