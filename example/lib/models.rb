require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'

require 'ixtlan/datamapper/optimistic_get'
require 'ixtlan/datamapper/conditional_get'

require 'groups/model'
require 'users/model'

DataMapper.setup( :default, "sqlite:#{File.expand_path(File.dirname(__FILE__))}/../db/development.sqlite" )
DataMapper.finalize
DataMapper.auto_upgrade!
