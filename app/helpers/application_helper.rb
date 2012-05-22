module ApplicationHelper
  def getFullUserName(user)
    user.family_name.to_s << ' ' << user.given_name.to_s << ' (' << user.login.to_s << ')'
  end
end
