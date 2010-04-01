module MadWombat
    module Mail
	class BodyPart
	    include_class javax.mail.internet.MimeBodyPart
	    include_class java.io.ByteArrayOutputStream
	    include_class javax.mail.internet.ContentType

	    attr_reader :parent

	    #
	    # We really just act as a simple wrapper to MimeBodyPart;
	    # any hash passed to the constructor will just have all its
	    # keys executed as methods, with the value providing the
	    # arguments.
	    #
	    def initialize(part = nil, parent = nil)
	        @part = (part or MimeBodyPart.new)
		@parent = parent
	    end

	    #
	    # Returns the base content type, minus character sets and
	    # encoding information.
	    #
	    def content_type
		type = header('Content-Type') or return
	        ContentType.new(type).getBaseType
	    end

	    #
	    # Returns the character set we're encoded in.
	    #
	    def charset
		type = header('Content-Type') or return
	        ContentType.new(type).getParameter('charset')
	    end

	    #
	    # If this is an attachment, returns the file name.
	    #
	    def filename
	        @part.getFileName
	    end

	    #
	    # Returns true if this is a multipart message.
	    #
	    def multipart?
		@part.content.is_a?(javax.mail.Multipart)
	    end

	    #
	    # Returns the body parts of the multipart we contain.
	    #
	    def body_parts
	        return unless multipart?
		[ self, Multipart.new(@part.content).body_parts ]
	    end

	    #
	    # Return the selected headers.
	    #
	    def headers(*list)
		names = list.flatten
		results = @part.getAllHeaders.map { |h| [ h.name, h.value ] }
		return(results) if names.empty?
		return(results.select { |h| list.include?(h.first) })
	    end

	    #
	    # Return just a single header.
	    #
	    def header(name)
		result = headers(name)
		return if result.empty?
		result.first[1]
	    end

	    #
	    # Returns the original contents of this BodyPart.
	    #
	    def read
		output = ByteArrayOutputStream.new
		input = @part.getInputStream
		while((byte = input.read) != -1)
		    output.write(byte)
		end
		output.close
		String.from_java_bytes(output.toByteArray)
	    end

	    #
	    # Returns a string representation of this BodyPart.
	    #
	    def to_s
	        return unless (content_type =~ /^text\//)
	        @part.content
	    end

	    #
	    # Return the Java object that we wrap.
	    #
	    def to_java
	        @part
	    end

	    #
	    # Hand unknown method calls off to the object we wrap.
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
