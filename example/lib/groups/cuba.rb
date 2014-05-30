require 'groups/filter_serializer'

module Groups
  class Cuba < ::Cuba

    define do

      on_path do

        # GET ALL
        on get do
          res.browser_proxy_cache( 1440 ) # one day
          write( Group.all, :list )
        end

        # CREATE
        on post do
          data = read( GroupFilter )

          g = Group.new( data.attributes )
          g.save

          write g
        end
      end

      on_path :id do |id|

        # GET
        on get do
          if result = Group.conditional_get!( modified_since, id )
            res.last_modified( result.updated_at )
            res.browser_proxy_cache( 1440 * 365 ) # one year
            write result
          else
            res.last_modified( modified_since )
          end
        end
        
        # DELETE
        on delete do
          data = read( Ixtlan::Babel::UpdatedAtFilter )
          
          g = Group.optimistic_get!( data.updated_at, id )
          g.destroy
          
          # if g is valid no content is written
          write g
        end
      end
    end
  end
end
