# -*- coding: utf-8 -*-

class GlobalSetting < ActiveRecord::Base
  attr_accessible :name,:matching_range,:maximum_range,:matching_interval

  # システム設定のデフォルト
  DEFAULTS = {:name => "だんだんマッチング",
              :matching_range=> 1,
              :maximum_range=>300,
              :matching_step=>1,
              :matching_interval=>10}

  @@instance = nil

  # システム設定情報の取得用アクセサ
  def self.[](value)
    return self.get_instance[value]
  end

  # レコードの取得
  def self.get_instance
    if self.all.size == 0
      return self.create(DEFAULTS)
    else
      @@instance = GlobalSetting.first unless @@instance
      return @@instance
    end
  rescue
    return DEFAULTS
  end
end
