$LOAD_PATH << File.dirname( __FILE__ )

require 'dm-core'
DataMapper::Logger.new(STDOUT, :debug)

require 'models'

Group.create( :name => 'root' ) unless Group.first( :name => 'root' )
User.create( :login => 'root' ) unless User.first( :login => 'root' )
