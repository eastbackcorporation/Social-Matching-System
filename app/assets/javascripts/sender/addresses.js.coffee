# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ -> 
  $.mask.masks.postal_code = {mask: '999-9999'}
  $('#address_postal_code').setMask();
  
  #モバイル画面用
  $('#address_postal_code.ui-input-text').bind 'change', ->
    AjaxZip3.zip2addr this,'','address[prefecture]','address[address1]','address[address2]'
    return
  
  #モバイル画面用
  #郵便番号から住所を取得してセレクトボックスを更新する際にjQueryMobileのUIも更新する
  AjaxZip3.afterZip2addr = ->
    if $('#address_prefecture').selectmenu
      $('#address_prefecture').selectmenu('refresh');
    return
