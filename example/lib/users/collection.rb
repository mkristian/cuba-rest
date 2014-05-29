require 'ixtlan/datamapper/collection'
class UserCollection < Ixtlan::DataMapper::Collection
  
  attribute :users, Array[User]
  
  def data=( d )
    self.users = d
  end
end
