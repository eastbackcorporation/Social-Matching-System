# -*- coding: utf-8 -*-

#=== 共通設定画面コントローラ
class Admin::GlobalSettingsController < ApplicationController
  before_filter :require_user
  before_filter "check_role(:role=>:admin)".to_sym

  #編集画面表示
  def edit
    @global_setting = GlobalSetting.get_instance
  end

  #共通設定を更新
  def update
    @global_setting = GlobalSetting.get_instance
    if @global_setting.update_attributes(params[:global_setting])
      redirect_to "/", :notice => "共通設定を更新しました。"
    else
      render :action => "edit"
    end
  end
end
