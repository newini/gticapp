# TO aboid 'uninitialized constant ApplicationRecord' error due to version difference
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
