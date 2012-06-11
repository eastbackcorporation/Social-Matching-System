# -*- coding: utf-8 -*-

#=== マッチング(依頼情報)管理用コントローラ
class Admin::MassagesController < MassagesController
  before_filter :require_user
  before_filter "check_role(:role=>:admin)".to_sym

  respond_to :html,:json

  #依頼情報一覧表示
  def index
    @massages=Massage.paginate(:page => params[:page],:per_page=>10)
    respond_with() do |format|
        format.json {render :json => filter_on_params(Massage)}
    end
  end

  #依頼情報の詳細
  def show
    @massage=Massage.find(params[:id])
    @receivers=@massage.users
  end

  #ステータスの変更
  def change_status
    @massage = Massage.find(params[:id])
    if @massage.end_flg
      flash[:notice]="終了しているメッセージです"
      redirect_to(admin_massage_url)
    else
      @massage.update_attributes(:request_status_id=>params[:request_status])
      if @massage.save
        flash[:notice]="ステータス変更しました"
        redirect_to(admin_massage_url)
      else
        flash[:notice]="ステータス変更できませんでした"
        redirect_to(admin_massage_url)
      end
    end
  end
end
