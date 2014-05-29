require_relative 'spec_helper'
require 'cuba_rest/rack/mime_rack'
require 'cuba_rest/rest'
require 'cuba'
require 'json'
class E

  def id
    4711
  end

  attr_reader :message

  def initialize( args = nil )
    @errors = (args || {}).delete( :errors ) || {}
    # ruby18 workaround
    def @errors.to_s
      inspect
    end
    @message = args[ :message ] if args
    @attributes = args
  end
    
  def deleted?
    @attrbutes.nil?
  end

  def errors
    @errors
  end

  def to_s
    @attributes.inspect + @errors.inspect
  end
end

class ESerializer
  include Ixtlan::Babel::ModelSerializer

  attributes :id, :message
end


describe CubaRest::Rest do

  before do
    Cuba.reset!
    Cuba.use CubaRest::Rack::MimeRack
    Cuba.plugin CubaRest::Rest
    Cuba.define do
      on get do
        write E.new :errors => { :name => 'missing name' }
      end
      on post do
        write E.new :message => 'be happy' 
      end
      on put do
        write E.new :message => 'be happy' 
      end
      on delete do
        write E.new
      end
    end
  end

  let( :expected ){ {'id'=> 4711, 'message' => "be happy"}.to_yaml }
  it 'status 200' do
    status, _, resp = Cuba.call( { 'HTTP_ACCEPT' => 'application/json',
                                   'REQUEST_METHOD' => 'PUT' } )
    status.must_equal 200
    JSON.load( resp[0] ).to_yaml.must_equal expected
  end

  it 'status 201' do
    status, _, resp = Cuba.call( { 'HTTP_ACCEPT' => 'application/json',
                                   'REQUEST_METHOD' => 'POST' } )
    status.must_equal 201
    JSON.load( resp[0] ).to_yaml.must_equal expected
  end

  it 'status 204' do
    status, _, resp = Cuba.call( { 'HTTP_ACCEPT' => 'application/json',
                                   'REQUEST_METHOD' => 'DELETE' } )
    status.must_equal 204
    resp.must_equal []
  end

  it 'status 412' do
    status, _, resp = Cuba.call( { 'HTTP_ACCEPT' => 'application/json',
                                   'REQUEST_METHOD' => 'GET' } )
    status.must_equal 412
    JSON.load( resp[0] ).to_yaml.must_equal( { 'name' => 'missing name' }.to_yaml )
  end

end
