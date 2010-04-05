require 'mail'
require 'mail/message'
require 'digest/md5'

# Set us up to use Unicode.
require 'jcode'
$KCODE = 'u'

# Make referring to Mail objects easier.
include Mail

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
end
