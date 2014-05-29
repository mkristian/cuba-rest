require 'cuba_rest'

require 'models'

require 'groups/cuba'
require 'users/cuba'

# just make sure we use OJ if available
MultiJson.engine= :oj unless defined? JRUBY_VERSION rescue nil

class Cuba
  
  use Rack::ETag

  define do

    on "groups" do
      run Groups::Cuba
    end

    on "users" do
      run Users::Cuba
    end

  end
end
