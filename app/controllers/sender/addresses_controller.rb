# -*- coding: utf-8 -*-

# === 住所確認登録用コントローラ
class Sender::AddressesController < ApplicationController
  before_filter :require_user
  before_filter "check_role(:role=>:sender)".to_sym

  #現在の保持している住所一覧
  def index
    @addresses =Address.where(:user_id=>current_user.id)
  end

  #新規住所の登録画面
  def new
    @address=Address.new
   if mobile? then
      render :action => "new_mobile", :layout => 'mobile'
   end
  end

  #住所の編集画面
  def edit
    @address = Address.find(params[:id])
  end

  #'確認'ページ表示
  def confirm
    @address = Address.new(params[:address])
    if @address.valid?
      render :action => 'confirm'
    else
      render :action => 'new'
    end
  end

  #新規住所の登録
  def create
    @address = Address.new(params[:address])
    @address.update_attributes(:main=>false,:user_id=>current_user.id)

     respond_to do |format|
      if @address.save
        format.html { redirect_to sender_addresses_url, notice: '新規住所を登録しました' }
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
        format.html { redirect_to sender_addresses_path, notice: '住所を更新しました' }
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
    if @address.massages.size==0
      @address.destroy
    end

    respond_to do |format|
      format.html { redirect_to sender_addresses_url }
      format.json { head :no_content }
    end
  end
end
