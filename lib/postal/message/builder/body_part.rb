module Postal
    class BodyPartBuilder
	include_class javax.mail.util.ByteArrayDataSource
	include_class javax.activation.DataHandler
	include_class javax.mail.internet.ContentType

	#
	# Creates the builder, and executes the supplied block in the
	# object instance context.  If a hash is supplied, each key
	# is called (as an object instance method), and passed the 
	# value as a single parameter.
	#
	def initialize(*args, &block)
	    params = (args.last.is_a?(Hash) ? args.pop.dup : {})
	    @part = BodyPart.new(args.first)
	    @java = @part.to_java
	    evaluate(params, &block)
	end

	def evaluate(params = {}, &block)
	    params.each_pair { |k, v| send(k.to_sym, v) }
	    instance_eval(&block) if block_given?
	end

	#
	# Loads the file at [path] to this BodyPart, turning it into an
	# attachment.
	#
	def file(path, params = {})
	    params.each_pair { |k, v| self.send(k, v) }
	    @java.attachFile(path)
	end

	#
	# Like file(), but for arbitrary data, passed in binary form.
	# Automatically handles encoding, but a content-type must be set.
	#
	def data(data, params = {})
	    params.each_pair { |k, v| self.send(k, v) }
	    source = ByteArrayDataSource.new(data.to_java_bytes, 
		@java.get_content_type)
	    handler = DataHandler.new(source)
	    @java.setDataHandler(handler)
	end

	#
	# Adds a text body part.
	#
	def text(string, params = {})
	    @java.setText(string)
	    defaults = { :content_type => 'text/plain' }
	    defaults.merge(params).each_pair { |k, v| self.send(k, v) }
	end

	#
	# Sets our character set.
	#
	def charset(name)
	    type = ContentType.new(@part.header('Content-Type'))
	    type.setParameter('charset', name)
	    content_type(type.toString)
	end

	#
	# Sets the MIME Content-Type for this BodyPart; this must be called
	# if raw data is supplied via data().
	#
	def content_type(type)
	    setHeader('Content-Type', type)
	end

	def filename(name)
	    @java.setFileName(name)
	end

	#
	# Set a header for this BodyPart
	#
	def header(key, val)
	    @java.addHeader(key, val)
	end

	#
	# Returns the Java object backing this Builder
	#
	def to_java
	    @java
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
	    if(@java.respond_to?(name))
		@java.send(name, *args, &block)
	    else
		super
	    end
	end
    end
end
