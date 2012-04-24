# -*- coding: utf-8 -*-

#ユーザ管理用コントローラ
class Admin::UsersController < ApplicationController
  before_filter :require_user
  before_filter :check_admin

  respond_to :html,:json

  #ユーザの一覧表示
  def index
    respond_with() do |format|
      format.json {render :json => filter_on_params(User)}  
    end
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
  def create
    #auth_logicの動作によりユーザの新規作成にパスワード情報が必要のため、
    #grid_add()を使わずに直接操作する
    
    #grid_add(User)
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
  end

  def update
    #grid_edit(User)    
    @admin_user = User.find(params[:id])

    oldIds = @admin_user.role_ids
    oldIds.each{ |id| @admin_user.roles.delete(Role.find(id)) }
    newIds = params[:role_ids].sub(/(^\[)|(\]$)/,"").split(",")
    newIds.each {|id| 
      @admin_user.roles<<Role.find(id)
    }    

    @admin_user.update_attributes(
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
