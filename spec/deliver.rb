require 'postal'
require 'postal/message'
require 'digest/md5'

# Set us up to use Unicode.
require 'jcode'
$KCODE = 'u'

# Make referring to Mail objects easier.
include Postal

describe(Deliverator, '#new') do
    it 'delivers to Deliverator.mailbox' do
	Deliverator.mailbox.size.should == 0

        message = Message.new do
	    from 'support@madwombat.com'
	    to 'don@madwombat.com'
	    subject 'Pushing the Deliverator to his limits.'
	    text 'Go ahead.  Order a pizza.'
	end
	message.deliver

	Deliverator.mailbox.count.should == 1
	Deliverator.mailbox.pop.should == message.read
    end

    it 'batches deliveries in a threadlocal' do
	Deliverator.mailbox.size.should == 0

	lock = Mutex.new

        one = Thread.new do
	    message = Message.new do
		from 'support@madwombat.com'
		to 'don@madwombat.com'
		subject 'Pushing the Deliverator to his limits.'
		text 'Go ahead.  Order a pizza.'
	    end
	    message.deliver

	    sleep(0.2)

	    string = message.read
	    Deliverator.mailbox.pop.should == string
	    Message.new(string)
	end

        two = Thread.new do
	    message = Message.new do
		from 'support@madwombat.com'
		to 'don@madwombat.com'
		subject 'That Kourier saved my ass.'
		text 'Came out of nowhere, like that swimming pool.'
	    end
	    message.deliver

	    sleep(0.2)

	    string = message.read
	    Deliverator.mailbox.pop.should == string
	    Message.new(string)
	end

	alpha = one.value
	beta = two.value

	alpha.from.should == beta.from
	alpha.to.should == beta.to
	alpha.subject.should_not == beta.subject
    end

    it "delivers multiple messages" do
	message = Message.new do
	    from 'support@madwombat.com'
	    to 'don@madwombat.com'
	    subject 'Pushing the Deliverator to his limits.'
	    text 'Go ahead.  Order a pizza.'
	end
	message.deliver

	message = Message.new do
	    from 'support@madwombat.com'
	    to 'don@madwombat.com'
	    subject 'That Kourier saved my ass.'
	    text 'Came out of nowhere, like that swimming pool.'
	end
	message.deliver

	messages = Deliverator.mailbox.dup
	Deliverator.mailbox.clear
	messages.count.should == 2
	Deliverator.mailbox.count.should == 0

	deliverator = Deliverator.new
	deliverator.deliver(messages)
	Deliverator.mailbox.count.should == 2
	Deliverator.mailbox.clear

	deliverator.deliver(*messages)
	Deliverator.mailbox.count.should == 2
	Deliverator.mailbox.clear
    end
end
