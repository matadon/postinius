require 'java/mail.jar'
require 'open3'
require 'mail/message/multipart'
require 'mail/message/body_part'
require 'mail/message/builder'

module MadWombat
    module Mail
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
	    include_class java.lang.System
	    include_class java.io.ByteArrayInputStream
	    include_class java.io.ByteArrayOutputStream
	    include_class javax.mail.internet.MimeMessage
	    include_class javax.mail.Session
	    include_class javax.mail.Message
	    include_class javax.mail.internet.InternetAddress

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
	    def initialize(data, &block)
		# Set us up to work with JavaMail's MimeMessage.
		session = Session.getInstance(System.getProperties(), nil)
		@message = MimeMessage.new(session)
		@builder = MessageBuilder.new(@message)

		# Parse our input data.
		# FIXME: Do files directly via InputStream.
		if(data)
		    @message.parse(ByteArrayInputStream.new(data.to_java_bytes))
		end

		# Execute the builder if we got one.
		@builder.execute(&block) if block_given?
	    end

	    def recipients
		@message.getAllRecipients.map { |r| address_to_string(r) }
	    end

	    def to
		addresses = @message.getRecipients(Message::RecipientType::TO) 
		addresses.map { |a| address_to_string(a) } unless addresses.nil?
	    end

	    def cc
		addresses = @message.getRecipients(Message::RecipientType::CC) 
		addresses.map { |a| address_to_string(a) } unless addresses.nil?
	    end

	    def bcc
		addresses = @message.getRecipients(Message::RecipientType::BCC) 
		addresses.map { |a| address_to_string(a) } unless addresses.nil?
	    end

	    def subject
		@message.subject
	    end

	    def from
		address_to_string(@message.getFrom[0])
	    end

	    #
	    # Deliver our message
	    #
	    def deliver(method = nil)
		# Where is sendmail?
		Open3.popen3('sendmail -t') do |stdin, stdout, stderr|
		    stdin.write(self.write)
		end
		raise("Delivery via sendmail failed.") unless $?.success?
	    end

	    #
	    # Return the selected headers.
	    #
	    def headers(*names)
		names.flatten!

		if(names.empty?)
		    results = @message.getAllHeaders
		else
		    results = @message.getMatchingHeaders(names.to_java(:String))
		end

		results.map { |h| [ h.name, h.value ] }
	    end

	    #
	    # Return just a single header.
	    #
	    def header(name)
		result = headers(name)
		result.empty? and return
		result[0][1]
	    end

	    #
	    # Return the body of this message, either as text (if we're
	    # just a simple message), or as an array of Multiparts.
	    #
	    def body
		if(@message.content.is_a?(javax.mail.Multipart))
		    Multipart.new(@message.content)
		else
		    @message.content.toString
		end
	    end

	    #
	    # Returns all the files attached to this message.
	    #
	    def files
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

	    private

	    def address_to_string(address)
		if(personal = address.personal)
		    "#{address.personal} <#{address.address}>"
		else
		    address.address
		end
	    end
	end
    end
end
