module MadWombat
    module Mail
	class BodyPart
	    include_class javax.mail.internet.MimeBodyPart
	    include_class javax.mail.util.ByteArrayDataSource
	    include_class javax.activation.DataHandler
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
	    # Loads the file at [path] to this BodyPart, turning it into an
	    # attachment.
	    #
	    def file(path, params = {})
		params.each_pair { |k, v| self.send(k, v) }
		@part.attachFile(path)
	    end

	    #
	    # Like file(), but for arbitrary data, passed in binary form.
	    # Automatically handles encoding, but a content-type must be set.
	    #
	    def data(data, params = {})
		params.each_pair { |k, v| self.send(k, v) }
		source = ByteArrayDataSource.new(data.to_java_bytes, 
		    @part.get_content_type)
		handler = DataHandler.new(source)
		@part.setDataHandler(handler)
	    end

	    #
	    # Sets the MIME Content-Type for this BodyPart; this must be called
	    # if raw data is supplied via data().
	    #
	    def content_type=(type)
		header('Content-Type', type)
	    end

	    def content_type
	        ct = ContentType.new(getHeader('Content-Type').first)
		ct.getBaseType
	    end

	    def charset
	        ct = ContentType.new(getHeader('Content-Type').first)
		ct.getParameter('charset')
	    end

	    def filename
	        @part.getFileName
	    end

	    #
	    # Set a header for this BodyPart
	    #
	    def header(key, val)
		@part.addHeader(key, val)
	    end

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
