# -*- coding: utf-8 -*-

module ApplicationHelper
  def getFullUserName(user)
    user.family_name.to_s << ' ' << user.given_name.to_s
  end
end

def ja_error_messages_for(*params)
  result = error_messages_for(*params)
  result.sub!(/<h2>(\d+).*<\/h2>/) do
    "<h2>入力項目に#{$1}つのエラーがあります</h2>"
  end
  result.sub!(/<p>.*<\/p>/,"")
end
