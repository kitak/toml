module TOML  
  class Parser
    attr_reader :parsed

    def initialize(markup)
      # Make sure we have a newline on the end
      markup += "\n" unless markup.end_with?("\n")

      tree = Parslet.new.parse(markup)
      parts = Transformer.new.apply(tree)
      
      @parsed = {}
      @current = @parsed
      
      parts.each do |part|
        if part.is_a? Key
          @current[part.key] = part.value
        elsif part.is_a? KeyGroup
          resolve_key_group(part)
        else
          raise "Unrecognized part: #{part.inspect}"
        end
      end
    end
    
    def resolve_key_group(kg)
      @current = @parsed

      path = kg.keys.dup
      while k = path.shift
        if @current.has_key? k
          # pass
        else
          @current[k] = {}
        end
        @current = @current[k]
      end
    end
  end
end
