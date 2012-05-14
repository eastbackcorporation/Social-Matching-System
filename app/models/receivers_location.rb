#receiver の現在位置情報を記録する
#pending
class ReceiversLocation < ActiveRecord::Base
  attr_accessible :user_id,:latitude,:longitude
  belongs_to :user

  #DateTime p より後に更新された位置情報取得
  scope :all_at ,lambda{|p| where 'updated_at > ?', p}
end
