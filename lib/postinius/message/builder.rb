require 'postinius/message/builder/multipart'
require 'postinius/message/builder/body_part'

module Postinius
    class MimeMessageAlso < javax.mail.internet.MimeMessage
        #
	# Apparently, the shitheads that wrote JavaMail weren't
	# satisfied with an amazingly complex and inconsistent API.
	# They also wanted to randomly make you subclass and override
	# methods because they couldn't be bothered to check to see if
	# you already had a Message-ID header.
	#
	# Fucking morons.
	#
        def updateMessageID
	end
    end

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
		@message = MimeMessageAlso.new(session)
	    end

	    # Set a default message ID.
	    host = java.net.InetAddress.getLocalHost.getHostName
	    uuid = java.util.UUID.randomUUID
	    message_id("#{uuid}@#{host}")

	    # Evaluate the block we got passed.
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
	    @message.saveChanges
	end

	def clear_recipients
	    @message.setRecipients(Message::RecipientType::TO, "")
	    @message.setRecipients(Message::RecipientType::CC, "")
	    @message.setRecipients(Message::RecipientType::BCC, "")
	end

	def subject(subject)
	    @message.setSubject(subject)
	end

        def from(address)
            @message.setFrom(Address.create_from(address).to_java)
        end

        def to(address)
            @message.addRecipients(Message::RecipientType::TO, 
                Address.create_from(address).to_s)
        end

        def cc(address)
            @message.addRecipients(Message::RecipientType::CC, 
                Address.create_from(address).to_s)
        end

        def bcc(address)
            @message.addRecipients(Message::RecipientType::BCC, 
                Address.create_from(address).to_s)
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

	def add_body_part(*args, &block)
	    multipart.add_body_part(*args, &block)
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

	def message_id(id)
	    @message.removeHeader('Message-ID')
	    @message.setHeader('Message-ID', 
		"<#{id.gsub(/[\<\>]/, '')}>")
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
