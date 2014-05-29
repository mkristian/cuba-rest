require 'cuba_rest/rack/error_rack'
require 'cuba_rest/rack/mime_rack'
require 'cuba_rest/rest'
require 'cuba_rest/utils'
require 'cuba_rest/response'

class Cuba

  use CubaRest::Rack::ErrorRack
  use CubaRest::Rack::MimeRack
  use Rack::ConditionalGet
  
  plugin CubaRest::Rest
  plugin CubaRest::Utils
  
  settings[ :res ] = CubaRest::Response

end
