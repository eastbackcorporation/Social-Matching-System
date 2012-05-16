# -*- coding: utf-8 -*-

#=== 住所管理用コントローラ
#admin のみが情緒の管理が行える
class Admin::AddressesController < ApplicationController
  before_filter :require_user
  before_filter :check_admin

  #住所情報一覧
  def index
    @addresses = Address.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @addresses }
    end
  end

  #住所情報詳細表示
  def show
    @address = Address.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @address }
    end
  end

  #新規住所登録ページ表示
  def new
    @address = Address.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @address }
    end
  end

  #住所情報変更ページ表示
  def edit
    @address = Address.find(params[:id])
  end

  #住所情報作成
  def create
    @address = Address.new(params[:address])
    #@address.user=current_user
    @address.update_attributes(:main=>true)
    @address.update_attributes(:name=>"現住所")

    respond_to do |format|
      if @address.save
        format.html { redirect_to [:admin,@address], notice: 'Address was successfully created.' }
        format.json { render json: @address, status: :created, location: @address }
      else
        format.html { render action: "new" }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end

  #住所情報変更
  def update
    @address = Address.find(params[:id])

    respond_to do |format|
      if @address.update_attributes(params[:address])
        format.html { redirect_to [:admin,@address], notice: 'Address was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end

  #住所情報削除
  def destroy
    @address = Address.find(params[:id])
    @address.destroy

    respond_to do |format|
      format.html { redirect_to admin_addresses_url }
      format.json { head :no_content }
    end
  end
end
