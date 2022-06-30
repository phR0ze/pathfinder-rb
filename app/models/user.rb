class User < ApplicationRecord
  has_many :points
  has_many :rewards
end
