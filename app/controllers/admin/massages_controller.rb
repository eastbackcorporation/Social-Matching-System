# -*- coding: utf-8 -*-

#=== マッチング(依頼情報)管理用コントローラ
class Admin::MassagesController < ApplicationController
  before_filter :require_user
  before_filter "check_role(:role=>:admin)".to_sym

  respond_to :html,:json

  #依頼情報一覧表示
  def index
    @massages=Massage.all
    respond_with() do |format|
        format.json {render :json => filter_on_params(Massage)}
    end
  end

  #依頼情報の詳細
  def show
    @massage=Massage.find(params[:id])
    @receivers=@massage.users
  end
end
