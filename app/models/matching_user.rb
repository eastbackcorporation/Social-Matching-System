class MatchingUser < ActiveRecord::Base
  attr_accessible :massage_id,:receiver_id,:reject_flg
  belongs_to :user
  belongs_to :massage

  validates :massage_id ,:receiver_id,:presence =>true
end
