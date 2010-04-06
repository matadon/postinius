require 'postal/message/builder/multipart'
require 'postal/message/builder/body_part'

module Postal
    class MessageBuilder
	include_class java.lang.System
	include_class java.io.FileInputStream
	include_class java.io.ByteArrayInputStream
	include_class javax.mail.Session
	include_class javax.mail.Message
	include_class javax.mail.internet.MimeMessage

	def initialize(message = nil, params = {}, &block)
	    # Set us up to work with JavaMail's MimeMessage.
	    if(message)
		@message = message
	    else
		session = Session.getInstance(System.getProperties(), nil)
		@message = MimeMessage.new(session)
	    end

	    evaluate(params, &block)
	end

	def parse(input)
	    if(input.respond_to?(:to_path))
	        stream = FileInputStream.new(input.to_path)
	    else
		stream = ByteArrayInputStream.new(input.to_java_bytes)
	    end
	    @message.parse(stream)
	    stream.close
	end

	def evaluate(params = {}, &block)
	    params.each_pair { |k, v| send(k.to_sym, v) }
	    instance_eval(&block) if block_given?
	end

	def subject(subject)
	    @message.setSubject(subject)
	end

	def from(address)
	    @message.setFrom(Address.new(address).to_java)
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

	#
	# If called with a block, set up a new nested multipart.
	#
	def multipart(subtype = nil, params = {}, &block)
	    unless(@multipart)
		@multipart = MultipartBuilder.new(subtype)

		# Add our existing content in as the first body part
		@multipart.text(@message.getContent) unless empty?

		# Replace our content with the shiny new Multipart.
		@message.setContent(@multipart.to_java)
	    end

	    # Build nested multiparts if we got a block.
	    @multipart.multipart(subtype, params, &block) if block_given?

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

	def to_java
	    @message
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
