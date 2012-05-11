class Status < ActiveRecord::Base
  attr_accessible :name,:active_flg
  has_many :massages

  scope :to,lambda { |name| where(:name=>name) }
end
