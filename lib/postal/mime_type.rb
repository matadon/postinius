module Postal
    class MimeType
	include_class javax.mail.internet.ContentType

	#
	# Utility constructor; hands back the object if it's an address, 
	# builds a new one if not.  Helps us avoid needless object
	# churn.
	#
	def self.create_from(type)
	    return(type) if address.is_a?(self)
	    return(self.new(type))
	end

	def initialize(type = nil)
	    if(type.is_a?(ContentType))
	        @type = type
	    elsif(type.is_a?(self.class))
	        @type = type.to_java
	    elsif(type.nil? or type.empty?)
		@type = ContentType.new
	    else
		@type = ContentType.new(type) 
	    end
	end

	def empty?
	    @type.getBaseType == 'null/null'
	end

	def charset=(charset)
	    @type.setParameter('charset', charset)
	end

	def charset
	    @type.getParameter('charset')
	end

	def base
	    @type.getBaseType
	end

	def primary
	    @type.getPrimaryType
	end

	def subtype=(type)
	    @type.setSubType(type)
	end

	def subtype
	    @type.getSubType
	end

	def to_java
	    @type
	end

	def to_s
	    @type.to_string
	end

	def eql?(other)
	    if(other.is_a?(self.class))
		@type.match(other.to_java)
	    else
	        @type.match(other)
	    end
	end

	def ==(other)
	    eql?(other)
	end
    end
end
