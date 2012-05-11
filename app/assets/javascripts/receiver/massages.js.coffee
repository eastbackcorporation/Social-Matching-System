# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  timer = null
  intervalTime = 5000

  locations=new Array();

  ###
  #位置情報取得シミュレータ用の初期設定
  #シミュレータを使用する場合はコメントアウトを外して、geo_tool/geo_position_js_simulator.jsを読み込む
  locations.push
    coords:
      latitude : 41.399856290690956
      longitude : 2.1961069107055664
    duration : 5000

  locations.push
    coords:
      latitude : 41.400634242252046
      longitude : 2.1971797943115234
    duration : 5000

  locations.push
    coords:
      latitude : 41.40124586762545
      longitude : 2.197995185852051
    duration : 5000


  locations.push
    coords:
      latitude : 41.401921867919995
      longitude : 2.1977806091308594
    duration : 2000

  locations.push
    coords:
      latitude : 41.402533481174856
      longitude : 2.1977806091308594
    duration : 5000

  locations.push
    coords:
      latitude : 41.40308070920773
      longitude : 2.198038101196289
    duration : 7000

  locations.push
    coords:
      latitude : 41.40317727838223
      longitude : 2.1985530853271484
    duration : 5000

  geo_position_js_simulator.init locations
  ###

  success_callback = (p) ->
    console.log p.coords.latitude, p.coords.longitude
    if(current_user_id)
      $.ajax "/receiver/receivers_locations",
        type: "POST"
        data:
          user_id: current_user_id
          receivers_location:
            latitude: p.coords.latitude,
            longitude: p.coords.longitude
        success: (data, textStatus, jqXHR) ->
          console.log data
        error: (jqXHR, textStatus, errorThrown) ->
          console.log errorThrown
          
    return

  error_callback = (p) ->
    console.log 'error=' + p.message
    clearInterval timer


  if geo_position_js.init() && (typeof(current_user_id) != "undefined")
    clearInterval(timer);
    timer = setInterval ->
      geo_position_js.getCurrentPosition success_callback, error_callback
    , intervalTime
    
    #画面ロード時に一度だけ位置情報を取得する場合
    #geo_position_js.getCurrentPosition success_callback, error_callback
  else
    console.log "Geolocation Functionality not available"
    clearInterval timer
    
  #mobile画面用
  $("div#receiver_massage_index_mobile, div#receiver_massage_show_mobile, div#map_mobile_id").live "pageshow", ->
    if geo_position_js.init() && (typeof(current_user_id) != "undefined")
      clearInterval(timer);
      timer = setInterval ->
        geo_position_js.getCurrentPosition success_callback, error_callback
      , intervalTime
      
      #画面ロード時に一度だけ位置情報を取得する場合
      #geo_position_js.getCurrentPosition success_callback, error_callback
    else
      console.log "Geolocation Functionality not available"
      clearInterval timer
    
    
