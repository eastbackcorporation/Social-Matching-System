# -*- coding: utf-8 -*-

#ユーザ管理用コントローラ
class Admin::UsersController < ApplicationController
  before_filter :require_user
  before_filter :check_admin

  #ユーザの一覧表示
  def index
    @admin_users=User.all
  end

  def show
    @admin_user=User.find(params[:id])
  end
  #ユーザの新規登録画面表示
  def new
    @admin_user = User.new
  end

  #ユーザー情報編集フォームの表示
  def edit
    @admin_user = User.find(params[:id])
  end

  #ユーザの新規登録
  #TODO form_fordでなくform_tagを用いたため不格好
  def create
    @admin_user = User.new(
      :login=>params[:login],
      :email=>params[:email],
      :password=>params[:password],
      :password_confirmation=>params[:password_confirmation]
      )
    if params[:role] =="admin"
      @admin_user.roles<<Role.admin
    elsif params[:role] == "sender"
      @admin_user.roles<<Role.sender
    elsif params[:role] == "receiver"
      @admin_user.roles<<Role.receiver
    end
    if @admin_user.save
      flash[:notice] = 'ユーザを新規作成しました。'
      #redirect_to [:admin, @admin_user]

      render :show
    else
      flash[:notice] ='ユーザ新規登録しっぱい！'
      render :new
    end
  end

  def update
    @admin_user = User.find(params[:id])
    @admin_user.update_attributes(
      :login=>params[:login],
      :email=>params[:email],
      :password=>params[:password],
      :password_confirmation=>params[:password_confirmation]
      )
    @admin_user.roles.delete_all
    if params[:role] =="admin"
      @admin_user.roles<<Role.admin
    elsif params[:role] == "sender"
      @admin_user.roles<<Role.sender
    elsif params[:role] == "receiver"
      @admin_user.roles<<Role.receiver
    end
    if @admin_user.save
      flash[:notice] = 'ユーザを新規作成しました。'
      #redirect_to [:admin, @admin_user]

      render :show
    else
      flash[:notice] ='ユーザ新規登録しっぱい！'
      render :new
    end
  end
  # =ユーザーの削除
  # TODO: 実レコードの強制削除。関連レコードが全てアソシエーションに沿って正しく
  #       削除されているかどうか確認のこと。
  def destroy
    @admin_user = User.find(params[:id])
    @admin_user.destroy
    redirect_to(admin_users_url, :notice => 'ユーザー情報を削除しました。')
  end



end
