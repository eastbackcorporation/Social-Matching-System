# -*- coding: utf-8 -*-

#共通設定用モデル
class GlobalSetting < ActiveRecord::Base
  attr_accessible :name,:matching_range,:maximum_range,:matching_interval,:matching_step,:matching_number_limit,:mail_title_template,:mail_template

  validates_numericality_of :matching_range,:maximum_range,:matching_interval,:matching_step,:matching_number_limit


  # システム設定のデフォルト
  DEFAULT_MAIL_TEMPLATE=<<"EOS"
あなたがマッチングしました!!
EOS

  DEFAULTS = {:name => "だんだんマッチング",
              :matching_range=> 1.0,
              :maximum_range=>300.0,
              :matching_step=>1.0,
              :matching_interval=>10,
              :matching_number_limit=>100,
              :mail_title_template=>"あなたに依頼が来ています",
              :mail_template=>DEFAULT_MAIL_TEMPLATE}

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
  end
end
