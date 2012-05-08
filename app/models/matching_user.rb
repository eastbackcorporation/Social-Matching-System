class MatchingUser < ActiveRecord::Base
  attr_accessible :massage_id,:user_id,:reject_flg,:distance
  belongs_to :user
  belongs_to :massage

  validates :massage_id ,:user_id,:presence =>true
end
