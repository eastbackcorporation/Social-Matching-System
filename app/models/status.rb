class Status < ActiveRecord::Base
  attr_accessible :name,:active_flg
  has_many :massages
end
