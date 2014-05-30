#
# Copyright (C) 2012 Christian Meier
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
require 'cuba'
require 'rack/request'
require 'rack/utils'

begin
  require 'dm-core'
  require 'ixtlan/datamapper/stale_object_exception'
rescue LoadError
  # allow not datamapper also
end

module Cuba::Rest
  module Rack
    class ErrorRack

      class ErrorLogger
        def dump( e, env, session, params )
          warn "[Ixtlan::Errors] #{e.class}: #{e.message}"
        end
      end

      class DebugErrorLogger < ErrorLogger
        def dump( e, env, session, params )
          super
          warn "\t" + e.backtrace.join( "\n\t" ) if e.backtrace
        end
      end

      Logger = ErrorLogger

      ERROR_2_STATUS = { DataMapper::ObjectNotFoundError => 404, 
        Ixtlan::DataMapper::StaleObjectException => 409 } rescue {}

      def initialize( app, logger = Logger.new )
        @app = app
        @logger = logger
      end

      def error( status, e, env )
        req = ::Rack::Request.new( env )
        @logger.dump( e, env, req.session, req.params )
        [ status, 
          {'Content-Type' =>  'text/plain'}, 
          [ ::Rack::Utils::HTTP_STATUS_CODES[ status ] ] ]
      end

      def call(env)
        
        @app.call(env)
        
      rescue => e
        if status = ERROR_2_STATUS[ e.class ]
          error( status, e, env )
        else
          raise e
        end
      end
      
    end
  end
end
