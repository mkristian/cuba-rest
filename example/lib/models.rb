require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'

require 'ixtlan/datamapper/use_utc'
require 'ixtlan/datamapper/optimistic_get'
require 'ixtlan/datamapper/conditional_get'
require 'ixtlan/datamapper/validations_ext'

require 'groups/model'
require 'users/model'

DataMapper.setup( :default, 
                  ENV['DATABASE_URL'] || "sqlite:#{File.expand_path(File.dirname(__FILE__))}/../db/development.sqlite" )
DataMapper.finalize
DataMapper.auto_upgrade!
