#!/usr/bin/env ruby

require 'mail/message'

include MadWombat::Mail

message = Message.new do
    to "Don Werve <don.werve@gmail.com>"
    from "MadWombat Support <support@madwombat.com>"
    subject "Re: My wombat is all nobbly. [#33]"
    header 'X-Madwombat-Tracker-Ticket-Number', '33'

    text 'This is the message text.'

#    attach :file => "/Users/donw/tmp/dl/csstooltips.zip"
#
#    attach :data => File.read("/Users/donw/tmp/dl/jce_policy-6.zip"),
#	:content_type => 'application/zip',
#	:filename => 'custom-file-name.zip'
end

puts "from: #{message.from}"
puts "to: #{message.to}"
puts "subject: #{message.subject}"
puts
puts message.body
#.text

#message.files.each do |file|
#    puts "attached: #{file.filename} (#{file.size})"
#end


