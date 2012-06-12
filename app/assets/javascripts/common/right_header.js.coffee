#ロール変更による画面遷移
$ ->
  $("#role_change").change ->
    role=$(this).val()
    if role=="sender"
      location.href="/sender/massages"
    else if role=="receiver"
      location.href="/receiver/massages"