require_relative 'spec_helper'
require 'cuba/rest/rack/mime_rack'
require 'cuba/rest/plugin'
require 'cuba'

class D

  attr_accessor :attributes

  def initialize( args )
    @attributes = args
  end
end

class DFilter 
  include Ixtlan::Babel::HashFilter
  
  attribute :name
  hidden :age

end

class UpdateDFilter 
  include Ixtlan::Babel::HashFilter
  
  attribute :message
  hidden :age

end

describe Cuba::Rest::Plugin do

  before do
    Cuba.reset!
    Cuba.use Cuba::Rest::Rack::MimeRack
    Cuba.plugin Cuba::Rest::Plugin
    Cuba.define do
      on post do
        data = read( DFilter )
        attr = D.new( data.attributes ).attributes
        # whether hash is ordered-hash should not matter
        res.write attr.keys.sort.collect {|k| attr[k] }.join
      end
      on default do
        input = read( UpdateDFilter )
        res.write input.params['message'].to_s + input.age.to_s
      end
    end
  end

  it 'no json input' do
     _, _, resp = Cuba.call({'PATH_INFO' => '/'})
    resp.join.must_equal ''
  end

  it 'json input with attr and without keep' do
     _, _, resp = Cuba.call( 'PATH_INFO' => '/',
                             'CONTENT_TYPE' => 'application/json',
                             'rack.input' => StringIO.new( '{"name":"me","message":"be happy"}' ) )
    resp.join.must_equal 'be happy'
  end

  it 'json input with attr and  with keep' do
     _, _, resp = Cuba.call( 'PATH_INFO' => '/',
                             'CONTENT_TYPE' => 'application/json',
                             'rack.input' => StringIO.new( '{"name":"me","message":"be happy","age":45}' ) )
    resp.join.must_equal 'be happy' + "45"
  end

  it 'json input without attr and without keep' do
     _, _, resp = Cuba.call( 'PATH_INFO' => '/',
                             'CONTENT_TYPE' => 'application/json',
                             'rack.input' => StringIO.new( '{"something":"else"}' ) )
    resp.join.must_equal ''
  end

  it 'json input without attr and with keep' do
     _, _, resp = Cuba.call( 'PATH_INFO' => '/',
                             'CONTENT_TYPE' => 'application/json',
                             'rack.input' => StringIO.new( '{"something":"else","age":45}' ) )
    resp.join.must_equal "45"
  end

  it 'create new instance with json input' do
     _, _, resp = Cuba.call( 'PATH_INFO' => '/',
                             'CONTENT_TYPE' => 'application/json',
                             'REQUEST_METHOD' => 'POST',
                             'rack.input' => StringIO.new( '{"name":"me","message":"be happy","age":45}' ) )
    resp.join.must_equal 'me'
  end

end
