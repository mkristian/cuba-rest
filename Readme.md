
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
* there will one response instance per thread, i.e. even with composition you will have only **ONE** response object (unlike with upstream ```Cuba```)
* default response has content-type **text/plain** (unlike ```Cuba```)

## example ##

the example uses composition to have a similar directory as the API directory. i.e. all the 'users' stuff is in ```/users``` and all the 'groups' in ```/groups````.

the actual application (business logic) are models (```lib/models.rb```) the rest deals with HTTP layer of the application. when starting the ```lib/console.rb``` only the application gets loaded - no HTTP stuff.

it comes with ```Procfile``` and ```Gemfile``` for heroku. dito the database setup works with heroku as well.

