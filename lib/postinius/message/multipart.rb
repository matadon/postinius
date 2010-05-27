module Postinius
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
		p.multipart? ? p.body_parts : p }
	    parts.flatten.compact.each { |p| yield(p) }
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
	# Return the object that we wrap.
	#
	def to_java
	    @part
	end

	#
	# Returns true if this is a multipart message.  Which it is,
	# kind of obviously.  We use this to walk down the body part
	# tree, and search for all multiparts, including those
	# contained in other body parts.
	#
	def multipart?
	    true
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
