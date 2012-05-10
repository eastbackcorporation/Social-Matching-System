# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  timer = null
  intervalTime = 3000

  locations=new Array();

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

  #geo_position_js_simulator.init locations

  success_callback = (p) ->
    console.log p.coords.latitude, p.coords.longitude
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


  if geo_position_js.init()
    clearInterval(timer);
    timer = setInterval ->
      geo_position_js.getCurrentPosition success_callback, error_callback
    , intervalTime
    #geo_position_js.getCurrentPosition success_callback, error_callback
  else
    console.log "Geolocation Functionality not available"
    clearInterval timer

