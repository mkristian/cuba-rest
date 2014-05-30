require 'ixtlan/babel/factory'
require 'cuba'

if require 'multi_json'
  class Hash
    def to_json
      MultiJson.dump( self )
    end
  end
  class Array
    def to_json
      MultiJson.dump( self )
    end
  end
end

unless defined? YAML
  require 'safe_yaml' 
  SafeYAML::OPTIONS[ :default_mode ] = :safe
end

module Cuba::Rest

  module Plugin
    module ClassMethods
      def factory
        @_factory ||= Ixtlan::Babel::Factory.new
      end
    end
    
    def read( clazz )
      filter = clazz.new
      filter.replace( parse_request_body )
    end
    
    def write( obj, context = nil )
      audit( obj )
      obj = self.class.factory.serializer( obj, context )
      if mime = env[ 'MIME_EXT' ]
        res[ "Content-Type" ] = env[ 'HTTP_ACCEPT' ] + "; charset=utf-8"
        obj = handle_status( obj )
        res.write obj.send( "to_#{mime}" ) if obj
      else
        res.status = 406
        res.write "can not '#{env[ 'HTTP_ACCEPT' ] || 'unknown media type'}' consume"
      end
    end
    
    protected

    def audit( obj )
    end
    
    def handle_status( obj )
      if obj.respond_to?( :errors ) && obj.errors.size > 0
        res.status = 412 # Precondition Failed
        log_errors( obj.errors )
        obj.errors.to_hash
      elsif req.post?
        res.status = 201 # Created
        set_location( obj )
        obj
      elsif req.delete?
        res.status = 204 # No Content
        nil
      else
        obj
      end
    end

    def set_location( obj )
      if obj.respond_to?( :id ) && ! res[ 'Location' ]
        res[ 'Location' ] = env[ 'SCRIPT_NAME' ].to_s + "/#{obj.id}"
      end
    end
    
    def log_errors( errors )
      rest_logger.info do
        if errors.respond_to? :to_hash
          errors.to_hash.values.join( "\n" )
        else
          errors.inspect
        end
      end
    end
    
    def rest_logger
      @rest_logger ||= begin
                         logger_factory.logger( Rest )
                       rescue 
                         require 'logger'
                         Logger.new( STDERR )
                       end
    end

    def parse_request_body
      case env[ 'CONTENT_TYPE' ] 
      when /^application\/json/
        body = req.body.read
        body.empty? ? {} : MultiJson.load( body )
      when /yaml$/
        body = req.body.read
        body.empty? ? {} : YAML.parse( body )
      else
        {}
      end
    end
  end
end
