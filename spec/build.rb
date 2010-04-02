require 'mail'
require 'mail/message'
require 'digest/md5'

# Set us up to use Unicode.
require 'jcode'
$KCODE = 'u'

# Make referring to Mail objects easier.
include Mail

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
