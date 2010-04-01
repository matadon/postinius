module MadWombat
    module Mail
	class MultipartBuilder
	    #
	    # Creates the builder, and executes the supplied block in the
	    # object instance context.  Sets the Multipart sub-type If an 
	    # optional subtype is specified; otherwise, the subtype defaults
	    # to 'mixed'. 
	    #
	    # For more information on subtypes, see:
	    #
	    # http://en.wikipedia.org/wiki/MIME#Multipart_subtypes
	    #
	    def initialize(subtype = nil, params = {}, &block)
		@multipart = Multipart.new(subtype)
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
	    # Multiparts can be nested, so this creates a new nested
	    # MimeMultipart.  The most common use for this is specfiying
	    # 'multipart/alternative' sections for alternate representaton of
	    # the same content; for example, an email message in multiple
	    # languages.
	    #
	    # Note that we we have to wrap the subpart in a MimeBodyPart.
	    #
	    def multipart(subtype = nil, params = {}, &block)
		child = self.class.new(subtype, params, &block)
		wrapper = BodyPart.new(:content => child)
		@multipart.add(wrapper)
	    end

	    #
	    # Add a new body part to this MimeMultipart
	    #
	    def body_part(params = {}, &block)
		builder = BodyPartBuilder.new(params, &block)
		@multipart.add(builder.result)
	    end

	    #
	    # Shortcut to add a file as an attachment.  Parameters are 
	    # passed directly on to a BodyPartBuilder; some common 
	    # parameters are:
	    #
	    # [:file] A path to a file to attach; the base name (minus the path)
	    # of the file is used for the attachment filename.
	    #
	    # [:data] Raw data (passed as a String) to attach as a file.
	    #
	    # [:content_type] The attachment's MIME content-type.
	    #
	    # [:filename] The attachment filename.
	    #
	    def attach(params = {})
		defaults = { :content_type => 'application/octet-stream' }
	        body_part(defaults.merge(params))
	    end

	    #
	    # Shortcut to add a plaintext body part.
	    #
	    def text(string, params = {})
	        body_part(params) do
		    content_type('text/plain')
		    text(string)
		end
	    end

	    #
	    # Add an HTML body part.
	    #
	    def html(data, params = {})
	        body_part(params) do
		    content_type('text/html')
		    data(data)
		end
	    end

	    #
	    # Returns the Multipart produced by this builder.
	    #
	    def result
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
