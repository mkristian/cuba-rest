$LOAD_PATH.unshift File.expand_path( '../../lib', __FILE__ )

require "rack/test"
require 'cuba/test'
require 'awesome_print'

require 'cuba_rest/rack/error_rack'
# backtrace logger
#CubaRest::Rack::Logger = CubaRest::Rack::DebugErrorLogger

require 'root_cuba'

setup do
  { 'HTTP_ACCEPT' => 'application/json',
    'CONTENT_TYPE' => 'application/json' }
end
