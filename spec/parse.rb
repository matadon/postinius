require 'mail'
require 'mail/message'

# Set us up to use Unicode.
require 'jcode'
$KCODE = 'u'

# Make referring to Mail objects easier.
include Mail

# For each of the 'it_should_parse' methods below, we define an external
# function that sets up an 'it' rspec, and then load

def it_parses(description, &block)
    it(description) do
	filename = File.join('test', 'data', 
	    description.tr(' ', '-') + ".email")
	message = Message.read(filename)
	yield(message)
    end
end

describe(Message, '#new') do
    it_parses 'simple smtp message' do |message|
        message.from.should.eql?('donw@madwombat.com')
        message.to.should.eql?('support@widgets.madwombat.com')
	message.subject.should == 'A Christmas Carol'
	message.body.should =~ /Marley/
    end

#    it_parses 'simple japanese' do |message|
#    end
end

'forwarded multipart mime message'
'japanese body'
'japanese recipient'
'japanese sender'
'japanese subject'
'message to different address'
'mime multipart with attachments'
'mime multipart'
'multipart mime message in japanese'
'multipart mime message with attachment'
'multipart mime message'

#puts "from: #{message.from}"
#puts "to: #{message.to}"
#puts "subject: #{message.subject}"
#puts
#puts message.body.html
#
#message.files.each do |file|
#    puts "attached: #{file.filename} (#{file.size})"
#    File.open("foo", "w") { |f| f.write(file.read) }
#end

#MD5 (/Users/donw/tmp/dl/csstooltips.zip) = 99dd853c5398cd3292b2d7c743f45b1e
