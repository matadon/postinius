module MadWombat
    module Mail
	class BodyPartBuilder
	    #
	    # Creates the builder, and executes the supplied block in the
	    # object instance context.  If a hash is supplied, each key
	    # is called (as an object instance method), and passed the 
	    # value as a single parameter.
	    #
	    def initialize(params = {}, &block)
		@part = BodyPart.new
		params.each_pair { |k, v| self.send(k, v) }
		execute(&block) if block_given?
	    end

	    #
	    # Execute an arbitrary block in our instance context.
	    #
	    def execute(&block)
		instance_eval(&block)
	    end

	    #
	    # Returns the BodyPart produced by this Builder.
	    #
	    def result
		@part
	    end

	    #
	    # Hand unknown method calls off to the BodyPart that we're
	    # building.
	    #
	    # :nodoc:
	    #
	    def method_missing(name, *args, &block)
		if(@part.respond_to?(name))
		    @part.send(name, *args, &block)
		else
		    super
		end
	    end
	end
    end
end
