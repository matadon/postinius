require 'open3'

module Postinius
    class Deliverator
	def self.mailbox
	    Thread.current[:mailbox] ||= Array.new
	end

	# We default to not really delivering.
	@@delivery_method = :batch

	#
	# Sets the default delivery method.  The first call will set the
	# systemwide default, and the second will set it for the current
	# thread only.
	#
	def self.default_delivery_method=(method)
	    @@delivery_method = method
	end

	#
	# Sets the default delivery method for this thread.
	#
	def self.delivery_method=(method)
	    Thread.current[:delivery_method] = method
	end

	def self.default_delivery_method
	    @@delivery_method ||= nil
	end

	def self.delivery_method
	    Thread.current[:delivery_method] or default_delivery_method
	end

        def initialize(method = nil)
	    @method = (method or self.class.delivery_method)
	end

	def deliver(*messages)
	    messages.flatten.each do |message| 
		string = (message.is_a?(String) ? message : message.read)
		self.send(@method, string) 
	    end
	end

	private

	#
	# A batching delivery method that holds all messages sent in the
	# current thread in a threadlocal.  This threadlocal can later
	# be accessed through Deliverator.mailbox, and handed off for
	# delivery through another method.
	#
	def batch(message)
	    Thread.current[:mailbox] ||= Array.new
	    Thread.current[:mailbox] << message
	end

	#
	# Deliver a message via the local sendmail binary.
	#
	# FIXME: Path to sendmail?
	#
	def sendmail(message)
	    Open3.popen3('sendmail -t') do |stdin, stdout, stderr|
		stdin.write(message)
		stdin.close
	    end
	    raise("Delivery via sendmail failed.") unless $?.success?
	end
    end
end
