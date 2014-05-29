module CubaRest
  module Utils
    
    def empty_path
      Proc.new { env[ 'PATH_INFO' ].empty? }
    end

    def on_path( *args )
      args << empty_path
      on *args do |more|
        captures.push( *more )
        yield *captures
        # method not allowed
        res.status = 406 if res.status == 404
      end
    end

    # params
    def to_float( name, default = nil )
      v = req[ name ]
      if v
        v.to_f
      else
        default
      end
    end
    
    def to_int( name, default = nil )
      v = req[ name ]
      if v
        v.to_i
      else
        default
      end
    end
    
    def to_boolean( name, default = nil )
      v = req[ name ]
      if v
        v == 'true'
      else
        default
      end
    end
    
    def modified_since
      @modified_since ||=
        if date = env[ 'HTTP_IF_MODIFIED_SINCE' ]
          DateTime.parse( date )
        end
    end    
  end
end
