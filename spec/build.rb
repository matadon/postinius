require 'postal'
require 'postal/message'
require 'digest/md5'

# Set us up to use Unicode.
require 'jcode'
$KCODE = 'u'

# Make referring to Mail objects easier.
include Postal

describe(Message, '#new') do
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

	message.message_id.should == "<123456789@mail.madwombat.com>"
    end
 
    it 'generates a message ID' do
        message = Message.new do
	    subject "A test message."
	    text "This is some text."
	    from "root@madwombat.com"
	end

	message.message_id.should_not be_nil
	message.message_id.should_not be_empty
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

#    it 'builds a message with alternative english or japanese' do
#	message = Message.new do
#	    to "Don Werve <don.werve@gmail.com>"
#	    from "MadWombat Support <support@madwombat.com>"
#	    subject "Re: My wombat is all nobbly. [#33]"
#	    header 'X-Madwombat-Tracker-Ticket-Number', '33'
#	    text 'Seriously, totally nobbly.'
#	    html 'Seriously, <b>totally</b> nobbly.'
#
#	    multipart('alternative') do
#		text 'Some basic text.'
#
#		text 'これも簡単なテクストです。', :charset => 'UTF-8'
#	    end
#
#	    attach :file => "/Users/donw/tmp/dl/csstooltips.zip"
#
#	    attach :data => File.read("/Users/donw/tmp/dl/jce_policy-6.zip"),
#		:content_type => 'application/zip',
#		:filename => 'custom-file-name.zip'
#	end
#
#	Deliverator.mailbox.count.should == 1
#	Deliverator.mailbox.pop.should == message.read
#    end

end
