module Mail
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
	    "#{name} <#{address}>"
	end

	def to_rfc822
	    @address.toUnicodeString
	end

	def to_java
	    @address
	end

	def eql?(other)
	    other.address == self.address
	end
    end
end
