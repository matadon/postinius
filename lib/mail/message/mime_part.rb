module MadWombat
    module Mail
	class MimePart
	    include Enumerable

	    include_class javax.mail.internet.MimeMultipart

	    #
	    # We really just act as a simple wrapper to MimeMultipart;
	    # any hash passed to the constructor will just have all its
	    # keys executed as methods, with the value providing the
	    # arguments.
	    #
	    def initialize(multipart)
	        @multipart = MimeMultipart.new
	    end

	    #
	    # Sets our subtype.
	    #
	    def subtype=(subtype)
		@multipart.setSubType(subtype)
	    end

	    #
	    # Return an array of all the body parts we contain.
	    #
	    def body_parts
                @multipart.getContent.count.times.map { |i|
		    BodyPart.new(@multipart.getBodyPart(i)) }
	    end

	    #
	    # Implement each so we can mixin Enumerable.
	    #
	    def each
	        body_parts.each { |p| yield(p) }
	    end

	    #
	    # Return the first text/plain part that either we contain,
	    # or one of our subparts containes.
	    #
	    def text
	        body_parts.select { |b| b.text }
	    end

	    #
	    # Add in a new body part.
	    #
	    def add(part)
		@multipart.addBodyPart(part.to_java)
	    end

	    #
	    # Return the object that we wrap.
	    #
	    def to_java
	        @multipart
	    end

	    #
	    # Hand unknown method calls off to the Multpart that we're
	    # building.
	    #
	    # :nodoc:
	    #
	    def method_missing(name, *args, &block)
		if(@multipart.respond_to?(name))
		    @multipart.send(name, *args, &block)
		else
		    super
		end
	    end
	end
    end
end
