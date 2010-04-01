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
		@multipart = Multipart.new
		@java = @multipart.to_java
		@java.setSubType(subtype) if subtype
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
		wrapper = BodyPart.new
		wrapper.to_java.setContent(child.to_java)
		add(wrapper)
		child
	    end

	    #
	    # Add in a new body part.
	    #
	    def add(part)
		@java.addBodyPart(part.to_java)
	    end

	    #
	    # Add a new body part to this MimeMultipart
	    #
	    def add_body_part(params = {}, &block)
		builder = BodyPartBuilder.new(params, &block)
		add(builder)
		builder
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
	        add_body_part(defaults.merge(params))
	    end

	    #
	    # Shortcut to add a plaintext body part.
	    #
	    def text(string, params = {}, &block)
		defaults = { :text => string }
	        add_body_part(defaults.merge(params), &block)
	    end

	    #
	    # Add an HTML body part.
	    #
	    def html(string, params = {}, &block)
		defaults = { :content_type => 'text/html' }
	        text(string, defaults.merge(params), &block)
	    end

	    #
	    # Returns the Java object backing this Builder
	    #
	    def to_java
	        @java
	    end

	    #
	    # Returns the Multipart produced by this builder.
	    #
	    def result
	        @part
	    end

	    #
	    # Hand unknown method calls off to the Multpart that we're
	    # building.
	    #
	    # :nodoc:
	    #
	    def method_missing(name, *args, &block)
		if(@java.respond_to?(name))
		    @java.send(name, *args, &block)
		else
		    super
		end
	    end
	end
    end
end
