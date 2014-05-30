require 'cuba/rest/rack/error_rack'
require 'cuba/rest/rack/mime_rack'
require 'cuba/rest/plugin'
require 'cuba/rest/utils'
require 'cuba/rest/response'

class Cuba

  use Cuba::Rest::Rack::ErrorRack
  use Cuba::Rest::Rack::MimeRack
  use Rack::ConditionalGet
  
  plugin Cuba::Rest::Plugin
  plugin Cuba::Rest::Utils
  
  settings[ :res ] = Cuba::Rest::Response

end
