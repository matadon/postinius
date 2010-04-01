require 'mail/message/builder/multipart'
require 'mail/message/builder/body_part'

module MadWombat
    module Mail
	class MessageBuilder
	    include_class javax.mail.Message
	    include_class javax.mail.internet.InternetAddress

	    def initialize(message)
		@message = message
	    end

	    def subject(subject)
		@message.setSubject(subject)
	    end

	    def from(address)
		@message.setFrom(InternetAddress.new(address))
	    end

	    def to(address)
		@message.addRecipients(Message::RecipientType::TO, address)
	    end

	    def cc(address)
		@message.addRecipients(Message::RecipientType::CC, address)
	    end

	    def bcc(address)
		@message.addRecipients(Message::RecipientType::BCC, address)
	    end

	    def header(key, val)
		@message.addHeader(key, val)
	    end

	    def multipart(subtype = nil, &block)
	        @multipart ||= MultipartBuilder.new(@message, subtype)
		@multipart.execute(&block)
#		@builder.text(@message.getContent) unless empty?
#		@message.setContent(@builder.result)
#		@builder.execute(&block)
	    end

	    def attach(params)
#		multipart.e attach(params) }
	    end

	    # FIXME
	    def body(text)
#		if(@multipart)
#		    @multipart.execute { body(text) }
#		elsif(empty?)
#		    @message.setText(text)
#		end
	    end

	    #
	    # Returns true if this message has no content; we have to implement
	    # this via exceptions because JavaMail provides no way to ask if a
	    # message is empty.
	    #
	    def empty?
		begin
		    @message.getContent
		    return(false)
		rescue NativeException => exception
		    raise unless (exception.message =~ /java.io.IOException/)
		    raise unless (exception.message =~ /No content/i)
		    return(true)
		end
	    end

	    #
	    # Hand unknown method calls off to our Message.
	    #
	    # :nodoc:
	    #
	    def method_missing(name, *args, &block)
		if(@message.respond_to?(name))
		    @message.send(name, *args, &block)
		else
		    super
		end
	    end
	end
    end
end
