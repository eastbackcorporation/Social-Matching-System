# -*- coding: utf-8 -*-

#=== ユーザ管理用コントローラ
#admin のみがユーザの管理が行える
class Admin::UsersController < ApplicationController
  before_filter :require_user
  before_filter "check_role(:role=>:admin)".to_sym

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
    @errors = ""
  end

  #ユーザー情報編集フォームの表示
  def edit
    @admin_user = User.find(params[:id])
    #@addresses = Address.find(:all, :conditions => {:user_id => params[:id]})
    @addresses = @admin_user.addresses
    @roles = {}
    @admin_user.roles.each do |r|
      @roles[r.name] = r.id
    end
  end

  #ユーザの新規登録
  def create
    @admin_user = User.new(
      :login => params[:login],
      :email => params[:email],
      :password => params[:password],
      :password_confirmation => params[:password_confirmation],
      #:role => params[:role],
      :family_name => params[:family_name],
      :given_name => params[:givem_name],
      :family_name_kana => params[:family_name_kane],
      :given_name_kana => params[:given_name_kana],
      :sex => params[:sex]
    )

    roles = params[:roles]
    Role.all.each do |r|
      if roles.has_key?(r.name)
        @admin_user.roles << r
      end
    end

    address = Address.new(
      :prefecture => params[:prefecture],
      :postal_code => params[:postal_code],
      :address1 => params[:address1],
      :address2 => params[:address2],
      :name => params[:name],
      :main => 1
    )

    @admin_user.addresses << address

    respond_to do |format|
      if @admin_user.save
        format.html { redirect_to admin_users_url, notice: 'Address was successfully updated.' }
        format.json { head :no_content }
      else
        @errors = "/n"
        @admin_user.errors.entries.each do |error|
          @errors << "#{User.human_attribute_name(error[0])}: #{error[1]}/n"
        end
      @errors << "/n"

        format.html { render action: "new"}
        format.json { render json: @admin_user.errors, status: :unprocessable_entity }
      end
    end

  end

  #ユーザ情報の変更
  def update
    @admin_user = User.find(params[:id])

    #住所の変更
    addresses = params[:user][:addresses]
    addresses.each_pair do |key, value|
      if /^new/ =~ key
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

    #Roleの変更
    @admin_user.roles.clear
    roles = params[:user][:roles]
    Role.all.each do |r|
      if roles.has_key?(r.name)
        @admin_user.roles << r
      end
    end
    params[:user].delete('roles')


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

  # ユーザーの削除
  def destroy
    #住所の削除が必要　delete User.address
    @admin_user = User.find(params[:id])
    if @admin_user.address
      @admin_user.address.destroy
    end
    grid_del(User)
  end
end
