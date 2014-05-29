require 'ixtlan/datamapper/immutable'
class Group
  include DataMapper::Resource
  include Ixtlan::DataMapper::Immutable

  property :id, Serial
  property :name, String, :length => 16
  
  timestamps :at

end
