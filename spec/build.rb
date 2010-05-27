require 'postinius'
require 'postinius/message'
require 'digest/md5'

# Set us up to use Unicode.
require 'jcode'
$KCODE = 'u'

# Make referring to Mail objects easier.
include Postinius

describe('Builder') do
    it 'builds a new simple message' do
	message = Message.new do
	    to "Don Werve <don.werve@gmail.com>"
	    from "MadWombat Support <support@madwombat.com>"
	    subject "Re: My wombat is all nobbly. [#33]"
	    header 'X-Madwombat-Tracker-Ticket-Number', '33'
	    text 'Seriously, totally nobbly.  I can\'t use him anymore.'
	end

	message.to.count.should == 1
	message.to.first.should == 'don.werve@gmail.com'
	message.from.should == 'support@madwombat.com'
	message.subject.should == "Re: My wombat is all nobbly. [#33]"
	message.header('X-Madwombat-Tracker-Ticket-Number').should == "33"
	message.body.should =~ /totally/
    end

    it 'builds a message with alternative text or html' do
	message = Message.new do
	    to "Don Werve <don.werve@gmail.com>"
	    from "MadWombat Support <support@madwombat.com>"
	    subject "Re: My wombat is all nobbly. [#33]"
	    header 'X-Madwombat-Tracker-Ticket-Number', '33'
	    text 'Seriously, totally nobbly.'
	    html 'Seriously, <b>insanely</b> nobbly.'
	end

	message.body.count.should == 2
	message.body.text.content.should =~ /totally/
	message.body.html.content.should =~ /insanely/
	message.body.html.content.should =~ /\<b\>/
    end

    it 'builds a message from another message' do
        template = Message.new do
	    subject "A test message."
	    text "This is some text."
	end

	message = Message.new(template.read) do
	    from 'support@madwombat.com'
	    to 'don@madwombat.com'
	end

	message.body.should == "This is some text."
	message.subject.should == "A test message."
	message.from.should == 'support@madwombat.com'
	message.to.count.should == 1
	message.to.first.should == 'don@madwombat.com'
    end
    
    it 'provides access to the builder' do
        message = Message.new do
	    subject "A test message."
	    text "This is some text."
	end

	message.builder.evaluate do
	    to 'Don Werve <don@madwombat.com>'
	end

	message.builder.evaluate(:from => 'root@madwombat.com')

	message.body.should == "This is some text."
	message.subject.should == "A test message."
	message.from.should == 'root@madwombat.com'
	message.to.count.should == 1
	message.to.first.should == 'don@madwombat.com'
    end
    
    it 'lets me specify a message ID' do
        message = Message.new do
	    subject "A test message."
	    text "This is some text."
	    from "root@madwombat.com"
	    message_id "123456789@mail.madwombat.com"
	end

	parsed = Message.new(message.read)
	parsed.message_id.should == "<123456789@mail.madwombat.com>"
    end
 
    it 'generates a message ID' do
        message = Message.new do
	    subject "A test message."
	    text "This is some text."
	    from "root@madwombat.com"
	end
	parsed = Message.new(message.read)

	parsed.message_id.should_not be_nil
	parsed.message_id.should_not be_empty
    end
 
    it 'clears recipients' do
        message = Message.new do
	    subject "A test message."
	    text "This is some text."
	    from "root@madwombat.com"
	    to "don@madwombat.com"
	    cc "dave@madwombat.com"
	    clear_recipients
	    to "flufferton@madwombat.com"
	end

	message.to.count.should == 1
	message.to.first.should == "flufferton@madwombat.com"
	message.cc.should be_empty
	message.bcc.should be_empty
    end 

    it 'lets us reattach body parts' do
	file = 'test/data/mime-multipart-with-attachments.email'
        one = Message.read(file)

	two = Message.new
	one.files.each { |f| two.builder.add_body_part(f) }

	two.message_id.should_not == one.message_id
	two.files.count.should == one.files.count
	match = two.files.all? do |file|
	    checksum = Digest::MD5.hexdigest(file.read)
	    one.files.any? do |other|
		other.size == file.size \
		and other.content_type == file.content_type \
		and Digest::MD5.hexdigest(other.read) == checksum
	    end
	end
	match.should be_true
    end

    it 'attaches files to messages' do
        filename = "test/data/csstooltips.zip"
        message = Message.new do
	    subject "A test message."
	    from "root@madwombat.com"
	    to "don@madwombat.com"
	    text "This is some text."
	    attach :file => filename
	end

	checksum = Digest::MD5.hexdigest(File.read(filename))
	message.files.count.should == 1
	file = message.files.shift
	file.filename.should == 'csstooltips.zip'
	Digest::MD5.hexdigest(file.read).should == checksum
	file.content_type.should == 'application/octet-stream'
	file.disposition.should == 'attachment'
    end

    it 'attaches files-as-data to messages' do
        data = File.read("test/data/csstooltips.zip")

        message = Message.new do
	    subject "A test message."
	    from "root@madwombat.com"
	    to "don@madwombat.com"
	    text "This is some text."
	    attach :data => data, 
		:filename => 'foo.zip',
		:content_type => 'application/octet-stream'
	end

	checksum = Digest::MD5.hexdigest(data)
	message.files.count.should == 1
	file = message.files.shift
	file.filename.should == 'foo.zip'
	Digest::MD5.hexdigest(file.read).should == checksum
	file.content_type.should == 'application/octet-stream'
	file.disposition.should == 'attachment'
    end

#    it 'builds a message with alternative english or japanese' do
#	message = Message.new do
#	    to "Don Werve <don.werve@gmail.com>"
#	    from "MadWombat Support <support@madwombat.com>"
#	    subject "Re: My wombat is all nobbly. [#33]"
#	    header 'X-Madwombat-Tracker-Ticket-Number', '33'
#	    multipart('alternative') do
#		text 'Some basic text.'
#		text 'これも簡単なテクストです。', :charset => 'UTF-8'
#	    end
#	end
#    end
end
