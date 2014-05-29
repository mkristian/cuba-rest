$LOAD_PATH << File.dirname( __FILE__ )

require 'dm-core'
DataMapper::Logger.new(STDOUT, :debug)

require 'models'

unless defined? IRB
  require 'irb'
  IRB.start
end
