# -*- coding: utf-8 -*-

#依頼情報用の共通部分コントローラ
class MassagesController < ApplicationController

private
  #有効期限チェック
  def check_validated_datetime
    @massages = Massage.all
    @massages.each do |m|
      unless m.validated_datetime > DateTime.now
        m.status=Status.where(:name=> "期限切れ").first
        m.save
      end
    end
  end
end
