# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#
# index アクション用
#
#ページの自動更新
$ ->
  if $(location).attr('href').match(/\/sender\/massages$|\/sender\/massages\/all_index$/)
    setInterval ->
      document.location.reload(true)
    ,1*1*60*1000 #hour * min * sec *1000

#更新ボタンイベント
$ ->
  $("#update_button").click ->
    if $('#update_check').attr('checked')
      location.href="/sender/massages/all_index"
    else
      location.href="/sender/massages"
#更新のチェックボックス
$ ->
  $("#update_check").change ->
    if $(this).attr('checked')
      location.href="/sender/massages/all_index"
    else
      location.href="/sender/massages"

#
# show アクション用
#

#Map の作成
$ ->
  $("#map").hide()
  $("#show_map").click ->
    $("#map").slideToggle(this.checked)
    myLatlng = new google.maps.LatLng( $("#latitude").val(),$("#longitude").val() )
    myOptions =
      zoom: 13,
      center: myLatlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP

    map = new google.maps.Map(document.getElementById("map"), myOptions)
    marker = new google.maps.Marker(
      position: myLatlng,
      map: map
    )

#
# new(_form) アクション用
#

#備考欄の開閉
$ ->
  $("#description").hide()

$ ->
  $("#show_description").click ->
      $("#description").slideToggle(this.checked)


#住所セレクトした時に住所の内容を表示する
$ ->
  $("#massage_address_id").ready ->
    address_id = $("#massage_address_id option:selected").val()
    address =$("#hidden_address_"+address_id).val()
    if address_id==0
      $("#address_show").text("")
    else
      $("#address_show").text(address)

  $("#massage_address_id").bind 'change', ->
    address_id = $("#massage_address_id option:selected").val();
    address =$("#hidden_address_"+address_id).val();
    if address_id==0
      $("#address_show").text("")
    else
      $("#address_show").text(address)
#住所から緯度経度の取得
$ ->
  geocoderCallback = ( results, status ) ->
    if status == google.maps.GeocoderStatus.OK
      console.log results
      $('#massage_latitude').val( results[ 0 ].geometry.location.$a ) #緯度
      $('#massage_longitude').val( results[ 0 ].geometry.location.ab ) #経度
    else
      console.log 'Faild：' + status

  geocoder = new google.maps.Geocoder();
  geocoderRequest = address: ""

  #PC画面で住所選択時に位置情報を取得してフォームに値を挿入する
  $('#massage_address_id').bind 'change' ,->
    address_id = $("#massage_address_id option:selected").val();
    address =$("#hidden_address_"+address_id).val();
    console.log address
    geocoderRequest.address = address
    geocoder.geocode( geocoderRequest, geocoderCallback )
    return





  #モバイル画面で住所選択時に位置情報を取得してフォームに値を挿入する
  #$('select[name="massage[address_id]"]').live 'change', ->
  #  #address = $(this).prev().find(".ui-btn-text").text().replace(/.*:/,'').replace(/\s/g,'')
  #  address = $('#massage_address_id option:selected').text().replace(/.*:/,'').replace(/\s/g,'')
  #  console.log address
  #  geocoderRequest.address = address
  #  geocoder.geocode geocoderRequest, geocoderCallback
  #  return
