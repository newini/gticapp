class Category < ActiveRecord::Base
  has_one :user
end
