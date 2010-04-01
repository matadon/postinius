require 'mail/message/builder/multipart'
require 'mail/message/builder/body_part'

module MadWombat
    module Mail
	class MessageBuilder
	    include_class javax.mail.Message
	    include_class javax.mail.internet.InternetAddress

	    def initialize(message, &block)
		@message = message
		execute(&block) if block_given?
	    end

	    def execute(&block)
	        instance_eval(&block)
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
	        unless(@multipart)
		    @multipart = MultipartBuilder.new(subtype)

		    # Add our existing content in as the first body part
		    @multipart.text(@message.getContent) unless empty?

		    # Replace our content with the shiny new Multipart.
		    @message.setContent(@multipart.to_java)
		end

		@multipart.execute(&block) if block_given?
		@multipart
	    end

	    def attach(params, &block)
		multipart.attach(params, &block)
	    end

	    def text(string, params = {}, &block)
		if(empty?)
		    @message.setText(string)
		else
		    multipart.text(string, params, &block)
		end
	    end

	    def html(string, params = {}, &block)
		multipart.html(string, params, &block)
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
