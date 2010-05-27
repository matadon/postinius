module Postinius
    class Address
	include_class javax.mail.internet.InternetAddress

	#
	# Utility constructor; hands back the object if it's an address, 
	# builds a new one if not.  Helps us avoid needless object
	# churn.
	#
	def self.create_from(address)
	    return(address) if address.is_a?(self)
	    return(self.new(address))
	end

	def initialize(email = nil)
	    if(email.is_a?(javax.mail.internet.InternetAddress))
	        @address = email
	    elsif(email.is_a?(self.class))
	        @address = email.to_java
	    elsif(email.nil? or email.empty?)
		@address = InternetAddress.new
	    else
		@address = InternetAddress.new(email) 
	    end
	end

	def empty?
	    self.address.nil? \
		or self.address.empty? \
		or (@address.toString == 'null')
	end

	def name
	    @address.getPersonal
	end

	def name=(string)
	    @address.setPersonal(string)
	end

	def address
	    @address.getAddress
	end

	def address=(string)
	    @address.setAddress(string)
	end

	def to_s
	    return(address) unless name
	    "#{name} <#{address}>"
	end

	def to_rfc822
	    @address.toUnicodeString
	end

	def to_java
	    @address
	end

	def eql?(other)
	    if(other.is_a?(String))
		self.address == self.class.new(other).address
	    else
		self.address == other.address
	    end
	end

	def ==(other)
	    eql?(other)
	end
    end
end
