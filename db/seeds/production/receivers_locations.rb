#receiver の　現在位置情報のサンプルを作成

users=User.all

users.each do |user|
  if(user.roles.receiver)
    rLatitude=35.469051+(rand(180) - 180)/100.0
    rLongitude=133.061600+(rand(360)-360)/100.0
    ReceiversLocation.create(:user_id=>user.id,:latitude=>rLatitude.to_s,:longitude=>rLongitude.to_s)
  end
end
