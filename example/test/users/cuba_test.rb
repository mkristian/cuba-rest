require_relative '../cutest_helper'
require 'securerandom'

scope 'users' do
  test 'create user' do |data|
    post '/users', {}, data.merge( { :input => { 'name' => 'first'}.to_json } )
 
    assert_equal last_response.status, 201
    result = MultiJson.load last_response.body
    assert_equal result['name'], 'first'
  end

  test 'create user with validation error' do |data|
    post '/users', {}, data.merge( { :input => { 'name' => 'firstsssssssssssssss'}.to_json } )
 
    assert_equal last_response.status, 412
    result = MultiJson.load( last_response.body )
    assert result['name'] != nil
  end
 
  test 'get all users' do |data|
    get '/users', {}, data

    assert_equal last_response.status, 200
    result = MultiJson.load( last_response.body )

    assert_equal result[ 'offset' ], 0
    assert_equal result[ 'total_count' ], User.count
    assert result['users'].is_a?( Array )
    assert_equal result['users'].size, User.count
    assert_equal result['users'].last['id'], User.last.id

    etag = last_response.headers['ETag']
    get '/users', {}, data.merge( { 'HTTP_IF_NONE_MATCH' => etag } )
    assert_equal last_response.status, 304
  end

  test 'get some users' do |data|
    get '/users', {:offset => User.count - 1, :count => 1}, data

    assert_equal last_response.status, 200
    result = MultiJson.load( last_response.body )

    assert_equal result[ 'offset' ], User.count - 1
    assert_equal result[ 'total_count' ], User.count
    assert result['users'].is_a?( Array )
    assert_equal result['users'].size, 1
    assert_equal result['users'].last['id'], User.last.id

    etag = last_response.headers['ETag']
    get '/users', {:offset => User.count - 1, :count => 1}, data.merge( { 'HTTP_IF_NONE_MATCH' => etag } )
    assert_equal last_response.status, 304
  end

  test 'get user' do |data|
    get "/users/#{User.last.id}", {}, data

    assert_equal last_response.status, 200
    result = MultiJson.load( last_response.body )
    assert_equal result['id'], User.last.id 
    assert_equal result['name'], 'first' # last == first :)
  end

  test 'get user not found' do |data|
    get "/users/notanid", {}, data

    assert_equal last_response.status, 404
  end

  test 'get user not modified' do |data|
    last = User.last
    get "/users/#{last.id}", {}, data.merge({'HTTP_IF_MODIFIED_SINCE' =>
                                               last.updated_at.rfc2822})

    assert_equal last_response.status, 304
  end

  test 'not update user' do |data|
    put '/users', {}, data.merge( { :input => { 'name' => 'nomore'}.to_json } )

    assert_equal last_response.status, 406
    assert_equal last_response.body, ''
  end

  test 'update user with conflict' do |data|
    last = User.last
    put "/users/#{last.id}", {}, data.merge( { :input => { 'name' => 'nomore'}.to_json } )

    assert_equal last_response.status, 409
    assert_equal last_response.body, 'Conflict'
  end

  test 'update user with validation error' do |data|
    last = User.last
    put "/users/#{last.id}", {}, data.merge( { :input => { 'name' => 'nomore123456789012345', :updated_at => last.updated_at}.to_json } )

    assert_equal last_response.status, 412
    result = MultiJson.load last_response.body
    assert result['name'] != nil
  end

  test 'update user' do |data|
    last = User.last
    name = SecureRandom.hex( 4 ).to_s
    put "/users/#{last.id}", {}, data.merge( { :input => { 'name' => name, :updated_at => last.updated_at}.to_json } )

    assert_equal last_response.status, 200
    result = MultiJson.load last_response.body
    assert_equal result['name'], name
  end

  test 'delete user with conflict' do |data|
    delete "/users/#{User.last.id}", {}, data.merge( { :input => { 'updated_at' => "2001-01-21" }.to_json } )
 
    assert_equal last_response.status, 409
    assert_equal last_response.body, 'Conflict'
  end
 
  test 'delete user' do |data|
    last = User.last
    delete "/users/#{last.id}", {}, data.merge( { :input => { :updated_at => last.updated_at }.to_json } )
 
    assert_equal last_response.status, 204
    assert_equal last_response.body, ''
    assert User.get( last.id ).nil?
  end
 
end
