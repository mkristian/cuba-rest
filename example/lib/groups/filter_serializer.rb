require 'ixtlan/babel/common_filters'
require 'ixtlan/babel/model_serializer'

class ListGroupSerializer
  include Ixtlan::Babel::ModelSerializer

  attributes :id, :name
  
end

class GroupSerializer < ListGroupSerializer

  attributes :created_at
  
end

class GroupFilter
  include Ixtlan::Babel::HashFilter

  attributes :name
  
end
