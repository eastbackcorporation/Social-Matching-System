# -*- coding: utf-8 -*-

#共通設定用モデル
class GlobalSetting < ActiveRecord::Base
  attr_accessible :name,:matching_range,:maximum_range,:matching_interval,:matching_step,
                  :matching_number_limit,:mail_title_template,:mail_template,:validated_time_interval

  validates_numericality_of :matching_range,:maximum_range,:matching_interval,:matching_step,:matching_number_limit

  # システム設定のデフォルト
  DEFAULT_MAIL_TEMPLATE=<<"EOS"
あなたがマッチングしました!!

あなたのログイン名%receiver.login%

依頼カテゴリ%massage.category%
送信者メールアドレス: %sender.email%

依頼情報詳細 http://localhost:3000/%massage_path%
EOS

  DEFAULTS = {:name => "だんだんマッチング",
              :matching_range=> 1.0, #基準(最初の)マッチング範囲
              :maximum_range=> 300.0, #最大マッチング範囲
              :matching_step=> 1.0,  #拡大するときのマッチング範囲
              :matching_interval=>10, #再マッチングする時の時間
              :matching_number_limit=>100, #最大マッチング人数
              :validated_time_interval=>10*60, #位置情報の有効時間  10 * 60 秒= 10分
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
