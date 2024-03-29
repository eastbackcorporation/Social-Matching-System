# -*- coding: utf-8 -*-

#=== 依頼情報確認用コントローラ
class Receiver::MassagesController < MassagesController
  before_filter :require_user
  before_filter "check_role(:role=>:receiver)".to_sym

  respond_to :html,:json

  #自分宛の依頼情報一覧
  def index

    matching_users=MatchingUser.where(:user_id=>current_user.id)

    @massages = []
    ids = ""

    matching_users.each do |mu|
      unless mu.massage.end_flg
        @massages << mu.massage
      end
    end

    if mobile? then
      render :action => "index_mobile", :layout => 'mobile'
    else
      respond_with() do |format|
        format.json {render :json => filter_on_params(Massage)}
      end
    end
  end

  #詳細表示
  def show
    @massage=Massage.find(params[:id])
    if mobile? then
      render :action => "show_mobile", :layout => 'mobile'
    end
  end

  #ステータスの変更
  def change_status
    @massage = Massage.find(params[:id])
    unless @massage.end_flg
      if @massage.update_attributes(:request_status_id=>params[:request_status])
        flash[:notice]="ステータス変更しました"
        edirect_to(receiver_massage_url)
      else
        flash[:notice]="ステータス変更できませんでした"
        redirect_to(receiver_massage_url)
      end
    else
       flash[:notice]="終了しているメッセージです"
       redirect_to(receiver_massage_url)
    end
  end


  #mobile画面のGoogleMap
  def map
    @massage=Massage.find(params[:id])
    if mobile? then
      render :action => "map_mobile", :layout => 'mobile'
    else
      redirect_to :action => 'show', :id => params[:id]
    end
  end

  #依頼拒否用アクション
  def reject
    @matching_user=MatchingUser.where(:massage_id=>params[:id],:user_id=>current_user.id).first
    @matching_user.update_attributes(:reject_flg=>true)
    redirect_to(receiver_massages_path, :notice => "お断りしました")
  end
end
