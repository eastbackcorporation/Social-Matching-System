# -*- coding: utf-8 -*-

#依頼情報用の共通部分コントローラ
class MassagesController < ApplicationController

private
  #有効期限チェック
  def check_validated_datetime
    @massages = Massage.all
    @massages.each do |m|
      unless m.validated_datetime > DateTime.now || m.status.name=="完了" || m.status.name =="キャンセル"
        m.status=Status.where(:name=> "期限切れ").first
        m.save
      end
    end
  end

  #massageの状態チェック-before filter用
  def check_active
    @massages = Massage.all
    @massages.each do |m|
      if m.status.name=="完了" || m.status.name =="キャンセル" ||m.status.name =="期限切れ"
        m.active_flg=false
        m.save
      end
    end
  end
end
