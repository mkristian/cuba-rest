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
# -*- Coding: utf-8 -*-
require "cuba"
module Cuba::Rest

  class Response < Cuba::Response

    def self.new
      Thread.current[ :cuba_api_response ] ||= super
    end

    def initialize( status = 404,
                    headers = { "Content-Type" => "text/plain; charset=utf-8" } )
      super
    end

    def write( s )
      super
      @status = 200 if @status == 404
    end

    def finish
      Thread.current[ :cuba_api_response ] = nil
      super
    end

    # convenient method for status only responses
    def send_status( status )
      self.status = ::Rack::Utils.status_code( status )
      self.write ::Rack::Utils::HTTP_STATUS_CODES[ self.status ]
    end

    def last_modified( last )
      if last
        @status = 200 # for Rack::ConditionalGet
        self[ 'Last-Modified' ] = rfc2616( last )
        self[ 'Cache-Control' ] = "private, max-age=0, must-revalidate"
      end
    end

    def browser_proxy_cache( minutes )
      now = DateTime.now
      self[ 'Date' ] = rfc2616( now )
      self[ 'Expires' ] = rfc2616( now + minutes / 1440.0 )
      self[ 'Cache-Control' ] = "public, max-age=#{minutes * 60}"
    end
    
    def browser_only_cache( minutes = 0 )
      max = ( minutes * 60 ).to_s + (minutes == 0 ? ', must-revalidate' : '')
      self[ 'Date' ] = rfc2616
      self[ 'Expires' ] = "Fri, 01 Jan 1990 00:00:00 GMT"
      self[ 'Cache-Control' ] = "private, max-age=#{max}"
    end
    
    def browser_only_cache_no_store( minutes = 0 )
      browser_only_cache( minutes )
      self[ 'Cache-Control' ] += ", no-store"
    end
    
    def no_cache_no_store
      no_cache
      self["Cache-Control"] += ", no-store"
    end
    
    def no_cache
      self["Date"] = rfc2616
      self["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
      self["Pragma"] = "no-cache"
      self["Cache-Control"] = "no-cache, must-revalidate"
    end
    
    def content_type( mime )
      self[ 'Content-Type' ] = mime if mime
    end
    
    def rfc2616( time = DateTime.now )
      time.to_time.utc.rfc2822.sub( /.....$/, 'GMT')
    end
  end
end
