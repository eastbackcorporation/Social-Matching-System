# -*- coding: utf-8 -*-

#=== receiver の現在位置関連コントローラ
#実装中
class ReceiversLocationsController < ApplicationController
  before_filter :require_user

  #マッチングの一覧
  def index
    @receivers_locations=ReceiversLocation.all
  end
end
