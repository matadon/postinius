require 'postal/address'
require 'postal/message/multipart'
require 'postal/message/body_part'
require 'postal/message/builder'
require 'postal/deliverator'

module Postal
    #
    # Builds an email message using JavaMail.
    #
    # Examples:
    # 
    #    message = Message.new do
    #        to "Don Werve <don.werve@gmail.com>"
    #        from "MadWombat Support <support@madwombat.com>"
    #        subject "Re: My wombat is all nobbly. [#33]"
    #        header 'X-Madwombat-Tracker-Ticket-Number', '33'
    #    
    #        text 'This is the message text.'
    #    
    #        attach :file => "/path/to/some/file.zip"
    #    
    #        attach :data => File.read("/some/other/file.zip"),
    #            :content_type => 'application/zip',
    #            :file_name => 'custom-file-name.zip'
    #    end
    #
    #    message_as_text = message.write
    #
    class Message
	include_class java.io.ByteArrayOutputStream
	include_class javax.mail.Message

	RECIPIENT_TYPES = { 
	    :to => Message::RecipientType::TO,
	    :cc => Message::RecipientType::CC,
	    :bcc => Message::RecipientType::BCC }

	#
	# Read and parse a message from a file, handed over as a path.
	#
	def self.read(filename)
	    new(File.read(filename))
	end

	#
	# Create a new mail message.  If [data] is supplied in the form
	# of a string, then we parse the provided data with JavaMail.
	#
	# Alternatively, [data] can be supplied as a file, and we'll do
	# the right thing.
	#
	# If passed a block, will invoke that block in the context of
	# a MailBuilder.
	#
	def initialize(data = nil, &block)
	    @builder = MessageBuilder.new
	    @builder.parse(data) if data
	    @builder.evaluate(&block) if block_given?
	    @message = @builder.to_java
	end

	attr_reader :builder

	def recipients(type = nil)
	    if(type = RECIPIENT_TYPES[type])
	        recipients = @message.getRecipients(type)
	    else
		recipients = getAllRecipients
	    end
	    return(Array.new) if recipients.nil?
	    recipients.map { |r| Address.new(r) }
	end

	def to
	    recipients(:to)
	end

	def cc
	    recipients(:cc)
	end

	def bcc
	    recipients(:bcc)
	end

	def subject
	    @message.subject
	end

	def from
	    Address.new(@message.getFrom[0])
	end

	def message_id
	    @message.getMessageID
	end

	#
	# Send our message out into the wild black yonder.
	#
	def deliver(method = nil)
	    deliverator = Deliverator.new(method)
	    deliverator.deliver(self)
	end

	#
	# Return the selected headers.
	#
	def headers(*list)
	    names = list.flatten
	    results = @message.getAllHeaders if names.empty?
	    results ||= @message.getMatchingHeaders(names.to_java(:String))
	    results.map { |h| [ h.name, h.value ] }
	end

	#
	# Return just a single header.
	#
	def header(name)
	    result = headers(name) or return
	    return if result.empty?
	    result.first[1]
	end

	#
	# Return the body of this message, either as text (if we're
	# just a simple message), or as an array of Multiparts.
	#
	def body
	    if(multipart?)
		Multipart.new(@message.content)
	    else
		@message.content
	    end
	end

	#
	# Returns the plaintext from the message body; if there is no
	# plaintext body, returns nil.
	#
	def text
	    if(multipart?)
	        body.text
	    else
	        body
	    end
	end

	#
	# Returns the HTML message body.
	#
	def html
	    return unless multipart?
	    body.html
	end

	#
	# Returns true if this is a multipart message.
	#
	def multipart?
	    @message.content.is_a?(javax.mail.Multipart)
	end

	#
	# Returns all the files attached to this message.
	#
	def files
	    return(Array.new) unless multipart?
	    body.select { |p| p.disposition == 'attachment' }
	end

	#
	# Return the contents of this message as a string, a-la
	# File.read
	#
	def read
	    output = ByteArrayOutputStream.new
	    @message.writeTo(output)
	    String.from_java_bytes(output.toByteArray)
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
