require 'ixtlan/datamapper/collection'
class User
  include DataMapper::Resource

  property :id, Serial
  property :login, String
  property :name, String, :length => 16
  property :email, String
  
  timestamps :at

  has n, :groups, :through => Resource

  def update_groups( groups )
    groups ||= []
    new_groups = groups.collect do |g|
      Group.get( g.id  )
    end
    self.groups.delete_if { |g| not new_groups.member?( g ) }
    self.groups += new_groups
  end
end
