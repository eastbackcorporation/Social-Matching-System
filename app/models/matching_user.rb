class MatchingUser < ActiveRecord::Base
  attr_accessible :massage_id,:receiver_id
  belongs_to :users
  belongs_to :massages

  validates :massage_id ,:receiver_id,:presence =>true
end
