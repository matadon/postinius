module Postal
    class Address
	include_class javax.mail.internet.InternetAddress

	def initialize(email = nil)
	    if(email.nil?)
		@address = InternetAddress.new
	    elsif(email.is_a?(javax.mail.internet.InternetAddress))
	        @address = email
	    elsif(email.is_a?(self.class))
	        @address = email.to_java
	    else
		@address = InternetAddress.new(email) 
	    end
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
