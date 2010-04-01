module MadWombat
    module Mail
	class Multipart
	    include Enumerable
	    include_class javax.mail.internet.MimeMultipart

	    attr_reader :parent

	    #
	    # We really just act as a simple wrapper to MimeMultipart;
	    # any hash passed to the constructor will just have all its
	    # keys executed as methods, with the value providing the
	    # arguments.
	    #
	    def initialize(part = nil, parent = nil)
	        @part = (part or MimeMultipart.new)
		@parent = parent
	    end

	    #
	    # Sets our subtype.
	    #
	    def subtype=(subtype)
		@part.setSubType(subtype)
	    end

	    #
	    # Return an array of all the body parts we contain.
	    #
	    def body_parts
                @part.getCount.times.map do |index|
		    part = @part.getBodyPart(index)
		    next(BodyPart.new(part, self)) \
			unless @message.is_a?(javax.mail.Multipart)
		    Multipart.new(part, self)
		end
	    end

	    #
	    # Implement each so we can mixin Enumerable.  Note that we
	    # go a little farther here, and iterate not only over all
	    # our body parts, but over any multiparts that we contain.
	    #
	    def each
	        parts = body_parts.map { |p| 
		    p.is_a?(BodyPart) ? p : p.body_parts }
	        parts.each { |p| yield(p) }
	    end

	    #
	    # Return the first text/plain part that either we contain,
	    # or one of our subparts containes.
	    #
	    def text
	        find { |b| b.content_type == 'text/plain' }
	    end

	    #
	    # Return the first text/plain part that either we contain,
	    # or one of our subparts containes.
	    #
	    def html
	        find { |b| b.content_type == 'text/html' }
	    end

	    #
	    # Add in a new body part.
	    #
	    def add(part)
		@part.addBodyPart(part.to_java)
	    end

	    #
	    # Return the object that we wrap.
	    #
	    def to_java
	        @part
	    end

	    #
	    # Hand unknown method calls off to the Multpart that we're
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
