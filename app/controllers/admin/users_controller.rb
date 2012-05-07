# -*- coding: utf-8 -*-

#ユーザ管理用コントローラ
#admin のみがユーザの管理が行える
class Admin::UsersController < ApplicationController
  before_filter :require_user
  before_filter :check_admin

  respond_to :html,:json

  include ActiveModel::MassAssignmentSecurity
  attr_accessible :addresses_attributes, :user_id, :prefecture,:address1,:address2,:postal_code,:main,:name
  
  #ユーザの一覧表示
  def index
    respond_with() do |format|
      format.json {render :json => filter_on_params(User)}  
    end
  end

  #ユーザの詳細表示
  def show
    @admin_user = User.find(params[:id])
    @addresses = Address.find(:all, :conditions => {:user_id => params[:id]})
  end

  #ユーザの新規登録画面表示
  def new
    @admin_user = User.new
  end

  #ユーザー情報編集フォームの表示
  def edit
    @admin_user = User.find(params[:id])
    #@addresses = Address.find(:all, :conditions => {:user_id => params[:id]})
    @addresses = @admin_user.addresses
  end

  #ユーザの新規登録
  def create
    #auth_logicの動作によりユーザの新規作成にパスワード情報が必要のため、
    #grid_add()を使わずに直接操作する
    
    #grid_add(User)
    #ユーザを作成
    @admin_user = User.new(
      :login=>params[:login],
      :email=>params[:email],
      :password=>params[:password],
      :password_confirmation=>params[:password_confirmation],
      :family_name=>params[:family_name],
      :given_name=>params[:given_name],
      :family_name_kana=>params[:family_name_kana],
      :given_name_kana=>params[:given_name_kana],
      :sex=>params[:sex]
      )
    
    #ユーザに紐付く住所を作成
    @admin_user.address = Address.new(
        :postal_code => params["address.postal_code"],
        :prefecture => params["address.prefecture"],
        :address1 => params["address.address1"],
        :address2 => params["address.address2"],
    )

    if @admin_user.save
      render :json => [false, '', @admin_user] 
    else
      error_message = "<table>"
      @admin_user.errors.entries.each do |error|
        error_message << "<tr><td><strong>#{User.human_attribute_name(error[0])}</strong></td> <td>: #{error[1]}</td><td>"
      end
      error_message << "</table>"
      render :json =>[true, error_message, @admin_user]
    end
    
    
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

  #ユーザ情報の変更
  def update
    @admin_user = User.find(params[:id])
    
    addresses = params[:user][:addresses]
    
    addresses.each_pair do |key, value|
      if /^new/ =~ key
        #address = Address.new(value)
        #address.user = @admin_user
        @admin_user.addresses.build(value)
        #address.save
      else
        address = Address.find(key)
        if address
          if value["_delete"] && value["_delete"] == "1"
            address.destroy
          else
            address.update_attributes(value)
          end
        end
      end
      
    end

    params[:user].delete('addresses')

    respond_to do |format|
      if @admin_user.update_attributes(params[:user])
        format.html { redirect_to [:admin,@admin_user], notice: 'Address was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @admin_user.errors, status: :unprocessable_entity }
      end
    end

  end


  # =ユーザーの削除
  # TODO: 実レコードの強制削除。関連レコードが全てアソシエーションに沿って正しく
  #       削除されているかどうか確認のこと。
  def destroy
    #住所の削除が必要　delete User.address
    @admin_user = User.find(params[:id])
    if @admin_user.address
      @admin_user.address.destroy
    end
    grid_del(User)
  end
end
