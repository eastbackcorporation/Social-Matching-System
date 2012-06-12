# -*- coding: utf-8 -*-

#=== 位置情報確認用コントローラ
class Admin::ReceiversLocationsController < ApplicationController
  before_filter :require_user
  before_filter "check_role(:role=>:admin)".to_sym

  respond_to :html,:json

  #位置情報一覧表示
  def index
    @receivers_locations=ReceiversLocation.paginate(:page => params[:page],:per_page=>10)
    respond_with() do |format|
        format.json {render :json => filter_on_params(ReceiversLocation)}
    end
  end

  #位置情報の詳細表示
  def show
    @receivers_location=ReceiversLocation.find(params[:id])
  end
end
