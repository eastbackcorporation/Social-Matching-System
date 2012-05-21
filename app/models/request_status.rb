class RequestStatus < ActiveRecord::Base
  attr_accessible :name
  has_many :massages

  scope :to,lambda { |name| where(:name=>name) }
end
