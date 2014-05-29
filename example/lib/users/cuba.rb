require 'users/filter_serializer'
require 'users/collection'

module Users
  class Cuba < ::Cuba

    define do
      on_path :id do |id|
        
        # GET
        on get do
          if result = User.conditional_get!( modified_since, id )
            # privacy should be protected, i.e. name, email
            res.browser_only_cache_no_store

            res.last_modified( result.updated_at )

            write result
          else
            res.last_modified( modified_since )
          end
        end

        # UPDATE
        on put do
          data = read( UserFilter )

          u = User.optimistic_get!( data.updated_at, id )
          u.attributes = data.attributes
          u.update_groups( data.groups )
          u.save

          res.browser_only_cache_no_store

          write u
        end

        # DELETE
        on delete do
          data = read( Ixtlan::Babel::UpdatedAtFilter )

          u = User.optimistic_get!( data.updated_at, id )
          u.destroy

          # if u has no errors then no content is written
          write u
        end
      end

      on_path do
        
        # GET SOME
        on get do
          res.browser_only_cache_no_store

          write UserCollection.new( User.all, 
                                    req[ 'offset' ],
                                    req[ 'count' ] )
        end

        # CREATE
        on post do
          data = read( CreateUserFilter )

          u = User.new( data.attributes )
          u.update_groups( data.groups )
          u.save

          res.browser_only_cache_no_store

          write u
        end
      end
    end
  end
end
