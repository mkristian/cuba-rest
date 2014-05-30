require_relative 'spec_helper'
require 'cuba/rest/rack/mime_rack'
require 'cuba/rest/plugin'
require 'cuba'

class B
  def name
    "hamster"
  end
end
class BSerializer
  include Ixtlan::Babel::ModelSerializer

  attribute :name
end

describe Cuba::Rest::Plugin do

  before do
    Cuba.reset!
    Cuba.use Cuba::Rest::Rack::MimeRack, [:yaml]
    Cuba.plugin Cuba::Rest::Plugin
    Cuba.define do
      on default do
        write B.new
      end
    end
  end

  let( :expected ) { {:name => 'hamster'}.to_yaml }
    
  it 'creates yaml' do
    skip("to_yaml add extra line with ...") if defined?( JRUBY_VERSION ) and (( JRUBY_VERSION =~ /^1.6./ ) == 0 ) and ( nil == (RUBY_VERSION =~ /^1.8/) )

    status, headers, resp = Cuba.call( { "SCRIPT_NAME" => "/bla.yaml",
                                         "PATH_INFO" => "/bla.yaml" } )
    resp[0].must_equal expected
    headers[ 'CONTENT_TYPE' ] = "text/yaml"
    status.must_equal 200

    status, headers, resp = Cuba.call( { "HTTP_ACCEPT" => "application/x-yaml",
                                         "PATH_INFO" => "/" } )
    resp[0].must_equal expected
    headers[ 'CONTENT_TYPE' ] = "text/yaml"
    status.must_equal 200

    status, headers, resp = Cuba.call({"HTTP_ACCEPT" => "text/yaml"})
    resp[0].must_equal expected
    headers[ 'CONTENT_TYPE' ] = "text/yaml"
    status.must_equal 200
  end

  it 'gives not found for not configured xml' do
    status, _, _ = Cuba.call( { "PATH_INFO" => "/",
                                "HTTP_ACCEPT" => "application/xml" } )
    status.must_equal 406

    status, _, _ = Cuba.call( { "SCRIPT_NAME" => "/bla.xml",
                                "PATH_INFO" => "/bla.xml" } )
    status.must_equal 406
  end

  it 'gives preference to script extension' do
    skip("to_yaml add extra line with ...") if defined?( JRUBY_VERSION ) and (( JRUBY_VERSION =~ /^1.6./ ) == 0 ) and ( nil == (RUBY_VERSION =~ /^1.8/) )

    status, headers, resp = Cuba.call( { "PATH_INFO" => "/bla.yaml",
                                   "SCRIPT_NAME" => "/bla.yaml",
                                   "HTTP_ACCEPT" => "application/xml" } )
    resp[0].must_equal expected
    headers[ 'CONTENT_TYPE' ] = "text/yaml"
    status.must_equal 200
  end
end
