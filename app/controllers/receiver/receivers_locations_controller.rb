# -*- coding: utf-8 -*-

#=== receiver の現在位置取得コントローラ
class Receiver::ReceiversLocationsController < ApplicationController
  before_filter :require_user
  before_filter :check_receiver

  #ビューからAjaxでポストされた位置情報を登録する
  def create
    @receivers_location = ReceiversLocation.find(:first, :conditions => {:user_id => params[:user_id]})

    if @receivers_location
      @receivers_location.update_attributes(params[:receivers_location])
    else
      @receivers_location = ReceiversLocation.new(params[:receivers_location])
      @receivers_location.update_attributes(:user_id => params[:user_id])
    end

    if @receivers_location.save
      render :json => {}
    else
      render :json => {}, :status => 500
    end
  end
end
