require_relative '../cutest_helper'

scope 'groups' do
  test 'create group' do |data|
    post '/groups', {}, data.merge( { :input => { 'name' => 'first'}.to_json } )
 
    assert_equal last_response.status, 201
    result = MultiJson.load last_response.body
    assert_equal result['name'], 'first'
  end

  test 'create group with validation error' do |data|
    post '/groups', {}, data.merge( { :input => { 'name' => 'firstsssssssssssssss'}.to_json } )
 
    assert_equal last_response.status, 412
    result = MultiJson.load( last_response.body )
    assert result['name'] != nil
  end
 
  test 'get all groups' do |data|
    get '/groups', {}, data

    assert_equal last_response.status, 200
    result = MultiJson.load( last_response.body )
    assert result.is_a?( Array )
    assert_equal result.last['id'], Group.last.id

    etag = last_response.headers['ETag']
    get '/groups', {}, data.merge( { 'HTTP_IF_NONE_MATCH' => etag } )
    assert_equal last_response.status, 304
  end

  test 'get group' do |data|
    get "/groups/#{Group.last.id}", {}, data

    assert_equal last_response.status, 200
    result = MultiJson.load( last_response.body )
    assert_equal result['id'], Group.last.id 
    assert_equal result['name'], 'first' # last == first :)
  end

  test 'get group not found' do |data|
    get "/groups/notanid", {}, data

    assert_equal last_response.status, 404
  end

  test 'get group not modified' do |data|
    last = Group.last
    get "/groups/#{last.id}", {}, data.merge({'HTTP_IF_MODIFIED_SINCE' =>
                                               last.updated_at.rfc2822})

    assert_equal last_response.status, 304
  end

  test 'update group' do |data|
    put '/groups', {}, data.merge( { :input => { 'name' => 'nomore'}.to_json } )
 
    assert_equal last_response.status, 406
    assert_equal last_response.body, ''
  end

  test 'delete group with conflict' do |data|
    delete "/groups/#{Group.last.id}", {}, data.merge( { :input => { 'updated_at' => "2001-01-21" }.to_json } )
 
    assert_equal last_response.status, 409
    assert_equal last_response.body, 'Conflict'
  end
 
  test 'delete group' do |data|
    last = Group.last
    delete "/groups/#{last.id}", {}, data.merge( { :input => { :updated_at => last.updated_at }.to_json } )
 
    assert_equal last_response.status, 204
    assert_equal last_response.body, ''
    assert Group.get( last.id ).nil?
  end
 
end
