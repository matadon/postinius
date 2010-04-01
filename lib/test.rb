#!/usr/bin/env ruby

require 'mail/message'

include MadWombat::Mail

file = 'forwarded_multipart_mime_message.email'
file = 'multipart_mime_message.email'
file = 'multipart_mime_message_with_attachment.email'
file = 'simple_smtp_message.email'
file = 'multipart_mime_message_in_japanese.email'
path = '/Users/donw/madwombat/src/tracker/test/data/email'

message = Message.read("#{path}/#{file}")

puts "from: #{message.from}"
puts "to: #{message.to}"
puts "subject: #{message.subject}"
puts
puts message.body
