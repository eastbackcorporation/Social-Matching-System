# -*- coding: utf-8 -*-

#ユーザ認証用
#authlogicにより管理を提供
class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  #新規ログイン画面の表示
  def new
    @user_session = UserSession.new
  end

  #ログイン
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default admin_users_url
    else
      render :action => :new
    end
  end

  #ログアウト
  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default :login
  end

end