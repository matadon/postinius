#!/usr/bin/env ruby

require 'mail/message'

require 'jcode'
$KCODE='u'

include MadWombat::Mail

message = Message.new do
    to "Don Werve <don.werve@gmail.com>"
    from "MadWombat Support <support@madwombat.com>"
    subject "Re: My wombat is all nobbly. [#33]"
    header 'X-Madwombat-Tracker-Ticket-Number', '33'

    text 'This is the message text.'

    html 'And some <b>HTML</b>.'

    multipart('alternative') do
        text 'Some basic text.'

	text 'これも簡単なテクストです。', :charset => 'UTF-8'
    end

    attach :file => "/Users/donw/tmp/dl/csstooltips.zip"

    attach :data => File.read("/Users/donw/tmp/dl/jce_policy-6.zip"),
	:content_type => 'application/zip',
	:filename => 'custom-file-name.zip'
end

puts "from: #{message.from}"
puts "to: #{message.to}"
puts "subject: #{message.subject}"
puts "parts: #{message.body.count}"
puts
puts message.body.text

#message.body.each do |p|
#    puts "part:   #{p} #{p.content_type} #{p.charset}"
#end

message.files.each do |file|
    puts "attached: #{file.filename} (#{file.size})"

    File.open(file.filename, "w") { |f| f.write(file.read) }
end
