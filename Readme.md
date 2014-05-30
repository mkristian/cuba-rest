# cuba rest #

* [![Build Status](https://secure.travis-ci.org/mkristian/cuba-rest.png)](http://travis-ci.org/mkristian/cuba-rest)
* [![Dependency Status](https://gemnasium.com/mkristian/cuba-rest.png)](https://gemnasium.com/mkristian/cuba-rest)
* [![Code Climate](https://codeclimate.com/mkristian/cuba-rest.png)](https://codeclimate.com/github/mkristian/cuba-rest)

this is a (hopefully) small collections of plugin, rack-middleware and datamapper extensions to build rest API servers with [cuba](http://github.com/soveran/cuba). most will work without datamapper - the ```Cuba::Rest::Rack::ErrorRack``` needs ```ERROR_2_STATUS``` to be setup as needed. probably the dependency to datamapper is still there.

## features ##

* input filter on POST/PUT data (json, yaml or maybe other formats)
* serializer for delivering json, yaml or maybe other formats
* helper methods in both cuba and the response object to implement conditional gets
* convert file extentions (.json, .yaml) to respective HTTP_ACCEPT
* restful response codes
  * 201 (created) with location header on POST request
  * 204 (no content) on DELETE request
  * 404 (conflict) triggered by any ```get!``` from datamapper in case the object does not exist
  * 409 (conflict) triggered by ```optimistic_get/optimistic_get!``` from ixtlan-datamapper
  * 412 (precondition failed) when output object responds to ```errors``` and is not empty
* datamapper extensions for optimistic persistence
* datamapper extensions for conditional get
* there will one ```Cuba::Rest::Response``` instance per thread, i.e. even with composition you will have only **ONE** response object (unlike with upstream ```Cuba```)
* default response has content-type **text/plain** (unlike ```Cuba```)
* default response has status **404** unless there was content written which gives **200** (unlike ```Cuba```)

## usage ##

just ```require 'cuba_rest'```. in case you want to customize or cherry pick things have a look at [lib/cuba/rest.rb](lib/cuba/rest.rb) to see how.

## consuming and producing json/yaml ##

the ```Cuba::Rest::Plugin``` has two methods for this ```read( FilterClass )``` and ```write( object )```/```write( object, context )```/```write( object, SerializerClass )```.

the ```FilterClass``` must of type ```Ixtlan::Babel::HashFilter```, an instance receives the payload from the client and ensures you get only the data you need for your business logic. the **Content-Type** on the request must be set correctly to parse the given payload.

the ```write``` method uses the ```Ixtlan::Babel::Factory``` to produces a serializer. if the ```object``` responds to ```errors``` and those ```errors``` are not empty then ***precondition failed** status is used along with payload of the serialized errors (Hash).

a **POST** request will use status **201** (created) along with a **Location** header (object must respond to ```id```)

for a **DELETE** request a status **204** (no content) is used.

## empty_path and on_path ##

there are some shortcuts to write up the cuba part:

    on_path :id do |id|
      on get do
        ...
	  end
    end

this is the same as

    on :id, empty_path do |id|
      on get do
        ...
	  end
	  res.status 406 # method not allowed
    end

where the empty_path is a matcher that all path was consumed.

## conditional get ##

to help there is a method ```modified_since``` in ```Cuba``` to retrieve the request header **IF_MODIFIED_SINCE** and a method ```last_modified``` in ```Cuba::Rest::Response``` (comes as default with cuba-rest) to set it for the response.

## Cuba::Rest::Utils ##

beside the extra matcher ```empty_path```, the ```on_path``` method and the ```modifed_since``` method, there are a couple of convienent methods to parse request parameters

* to_float( name, default = nil )
* to_int( name, default = nil )
* to_boolean( name, default = nil )

## Cuba::Rest::Response ##

there are a list of methods setting cache control headers on the response

* no_cache 
* no_cache\_no_store
* browser_proxy_cache( minutes ) 
* browser_only_cache( minutes ) 
* browser_only\_cache\_no_store( minutes )

expired by [ArticleHttpCaching](https://code.google.com/p/doctype-mirror/wiki/ArticleHttpCaching). more about caching is in [increasing-application-performance-with-http-cache-headers](https://devcenter.heroku.com/articles/increasing-application-performance-with-http-cache-headers).

other convenient methods are

* content_type( mime )
* rfc2616( time )
* send_status( status )
* last_modified( last )

it also default the response status to **404** unless there is some actual content. it will respect manual set response status.

## Cuba::Rest::Rack::MimeRack ##

per default ```Cuba::Rest::Rack::MimeRack``` consumes **application/json** and produces **application/json** and **text/x-yaml** as requested by the request. other media types (like XML) need to be configured and ```Hash``` and ```Array``` need to have respective method (like ```to_xml``` ) to work.

the request either can set the **HTTP_ACCEPT** to the desired media type or use the file extension **.json** or **.yaml** to trigger the right media. note that the file extension will **NOT** be passed on the ```Cuba``` matchers !

the main focus is JSON for input and output as well YAML as output since it produces nice on screen presentation.

## Cuba::Rest::Rack::ErrorRack ##

this rack middleware is meant to rescue from some exceptions/errors and produces given http status codes. per default it catches

* ```DataMapper::ObjectNotFoundError``` gives 404 (not found)
* ```Ixtlan::DataMapper::StaleObjectException``` gives 409 (conflict)

just add your exceptions and status to ```Cuba::Rest::Rack::ErrorRack::ERROR_2_STATUS```

it also logs a simple statement to console for each caught error. to produces a backtrace on the console log switch the logger to

    require 'cuba/rest/rack/error_rack'
    CubaRest::Rack::Logger = CubaRest::Rack::DebugErrorLogger

this must happen before requiring cuba-rest. NOTE bundler with its auto-require feature has to be off for cuba-rest

## example ##

it is fully working example with test and part of the test suite of cuba-rest.

the example uses composition of ```Cuba``` objects to have a similar directory structure as the API directory. i.e. all the 'users' stuff is in ```/users``` and all the 'groups' in ```/groups```.

the actual application (business logic) is inside the models (```lib/models.rb```). the cuba and filter/serializers deals with HTTP layer of the application. when starting the ```lib/console.rb``` only the application gets loaded - no HTTP stuff.

it comes with ```Procfile``` and ```Gemfile``` for heroku. dito the database setup works with heroku as well.

there are also a few convinient commands in example/bin to start the server, seed the database, start an irb session with the loaded models, or run the (cu)test. all those scripts use bundler to setup the load_path to use. bundler is only used when the **bin/load_path** is out of date.

note: this is basically my personal template for starting a new app ;)

# contributing #

1. fork it
2. create your feature branch (`git checkout -b my-new-feature`)
3. commit your changes (`git commit -am 'Added some feature'`)
4. push to the branch (`git push origin my-new-feature`)
5. create new pull request

# meta-fu #

enjoy :) 


