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



end
