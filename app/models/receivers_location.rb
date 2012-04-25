#receiver の現在位置情報を記録する
#pending
class ReceiversLocation < ActiveRecord::Base
  attr_accessible :user_id,:latitude,:longitude

  belongs_to :users
end
