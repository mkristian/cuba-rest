module CubaRest
  module Rack
    class MimeRack

      MIMES = { 'application/x-yaml' => :yaml,
        'text/yaml' => :yaml,
        'application/json' => :json,
        'application/xml' => :xml }

      def initialize( app,
                      produces = [ :json, :yaml ],
                      consumes = [ :json ] )
        @app = app
        @consumes = consumes.collect { |s| s.to_sym }
        @produces = produces.collect { |s| s.to_sym }
      end
      
      def call( env )
        process_file_extension( env )
        if produces?( env ) && consumes?( env )
          @app.call(env)
        else
          # Not Acceptable
          [ 406, {}, [] ]
        end
      end

      def produces?( env )
        mime_ext = MIMES[ env[ 'HTTP_ACCEPT' ] ]
        if mime_ext.nil?
          true
        elsif @produces.member?( mime_ext )
          env[ 'MIME_EXT' ] = mime_ext
          true
        else
          false
        end
      end

      def consumes?( env )
        env[ 'CONTENT_TYPE' ].nil? or @consumes.member?( MIMES[ env[ 'CONTENT_TYPE' ] ] )
      end

      def process_file_extension( env )
        path = env[ 'PATH_INFO' ]
        if path && path[ /\./ ]
          ext = path.sub( /.*\./, '' )
          mime = ::Rack::Mime.mime_type( '.' + ext )
          env[ 'PATH_INFO_ORIG' ] = path.dup
          env[ 'HTTP_ACCEPT' ] = mime
          env[ 'PATH_INFO' ].sub!( /\.[^.]*/, '' )
        end
      end
    end
  end
end
