# -*- coding: utf-8 -*-

#receiver の現在位置取得コントローラ
#このコントローラが必要かも含め検討中
class Receiver::ReceiversLocationsController < ApplicationController
  before_filter :require_user
  before_filter :check_receiver

  #現在位置の表示
  #TODO 開発用!
  def index
    @receivers_location=ReceiversLocation.where(:user_id=>current_user).first
  end

  #作成画面表示
  #TODO 開発用
  def new
    @raceivers_location=ReceiversLocation.where(:user_id=>current_user).first
    if @receivers_location
      render :edit
    else
      @receivers_location=ReceiversLocation.new
    end
  end

  #作成画面表示
  #TODO 開発用
  def edit
    @raceivers_location=ReceiversLocation.find()
  end

  #位置情報作成
  def create
    @receivers_location=ReceiversLocation.new(params[:receivers_location])
    @receivers_location.update_attributes(:user_id =>current_user.id)
    if @receivers_location.save
      render :index
    else
      render :index, :notice => "receivers_location#create error"
    end
  end

  #位置情報更新
  def update
    @receivers_location=ReceiversLocation.find(params[:id])
    @receivers_location.update_attributes(params[:receivers_location])

    render :index
  end
end
