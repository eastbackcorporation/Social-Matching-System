# -*- coding: utf-8 -*-

#receiver のr現在位置取得コントローラ
#このコントローラが必要かも含め検討中
class Receiver::ReceiversLocationsController < ApplicationController
  before_filter :require_user
  before_filter :check_receiver

  #位置情報作成
  def create
    @receivers_location=ReceiversLocation.new(:latitude=>params[:latitude],:longitude=>params[:longitude])

    render :index
  end

  #位置情報更新
  def update
    @receivers_location=ReceiversLocation.find(params[:id])
    @receivers_location.update_attributes(params[:latitude])
    @receivers_location.update_attributes(params[:longitude])

    render :index
  end
end
