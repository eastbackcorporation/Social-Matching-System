# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->      
  geocoderCallback = ( results, status ) ->
    if status == google.maps.GeocoderStatus.OK
      console.log results
      $('#massage_latitude').val results[ 0 ].geometry.location.$a #緯度
      $('#massage_longitude').val results[ 0 ].geometry.location.ab #経度      
    else
      console.log 'Faild：' + status


  geocoder = new google.maps.Geocoder();
  geocoderRequest = address: ""

  #PC画面で住所選択時に位置情報を取得してフォームに値を挿入する
  $('input[name="massage[address_id]"]:radio').change ->
    address = $(this).closest('li').find('[class="addressStr"]').text()
    console.log address
    geocoderRequest.address = address
    geocoder.geocode geocoderRequest, geocoderCallback
    return
    
  #モバイル画面で住所選択時に位置情報を取得してフォームに値を挿入する
  $('select[name="massage[address_id]"]').bind 'change', (event,ui) ->
    #address = $(this).prev().find(".ui-btn-text").text().replace(/.*:/,'').replace(/\s/g,'')
    address = $('#massage_address_id option:selected').text().replace(/.*:/,'').replace(/\s/g,'')
    console.log address
    geocoderRequest.address = address
    geocoder.geocode geocoderRequest, geocoderCallback
    return
