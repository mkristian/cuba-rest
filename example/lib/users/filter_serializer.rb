require 'ixtlan/babel/common_filters'
require 'ixtlan/babel/model_serializer'
require 'groups/filter_serializer'

class ListUserSerializer
  include Ixtlan::Babel::ModelSerializer

  attributes :id, :name, :login
end

class UserCollectionSerializer < Ixtlan::Babel::CollectionSerializer
  attribute :users, Array[ListUserSerializer]
end
  
class UserSerializer < ListUserSerializer
  attributes :email, :created_at, :updated_at
  attribute :groups, Array[ListGroupSerializer]
end

class UserFilter < Ixtlan::Babel::UpdatedAtFilter
  attributes :name, :email
  hidden :groups, Array[Ixtlan::Babel::IdFilter]  
end

class CreateUserFilter < UserFilter
  attributes :login
end
