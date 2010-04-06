require 'open3'

module Postal
    class Deliverator
        # For holding test deliveries.
        @@mailbox = Array.new

	def self.mailbox
	    @@mailbox
	end

	# We default to not really delivering.
	@@delivery_method = :test

	def self.delivery_method=(method)
	    @@delivery_method = method
	end

	def self.delivery_method
	    @@delivery_method
	end

        def initialize(method = nil)
	    @method = (method or self.class.delivery_method)
	end

	def deliver(message)
	    self.send(@method, message)
	end

	private

	#
	# A dummy delivery method for testing; messages can be accessed
	# via an array in Deliverator.mailbox
	#
	def test(message)
	    Deliverator.mailbox << message.read
	end

	#
	# Deliver a message via the local sendmail binary.
	#
	# FIXME: Allow the user to specify a sendmail delivery path.
	#
	def sendmail(message)
	    Open3.popen3('sendmail -t') do |stdin, stdout, stderr|
		stdin.write(message.read)
		stdin.close
	    end
	    raise("Delivery via sendmail failed.") unless $?.success?
	end
    end
end
