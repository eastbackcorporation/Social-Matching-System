# -*- coding: utf-8 -*-

# === 住所確認登録用コントローラ
class Sender::AddressesController < ApplicationController
  before_filter :require_user
  before_filter :check_sender

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

  #新規住所の登録
  def create
    @address = Address.new(params[:address])
    @address.update_attributes(:main=>false,:user_id=>current_user.id)

     respond_to do |format|
      if @address.save
        format.html { redirect_to new_sender_massage_url, notice: 'Address was successfully created.' }
        format.json { render json: @address, status: :created, location: @address }
      else
        format.html { render action: "new" }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end
end
