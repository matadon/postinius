require 'postal'
require 'postal/message'

# Set us up to use Unicode.
require 'jcode'
$KCODE = 'u'

# Make referring to Mail objects easier.
include Postal

describe('Message') do
    it 'performs case-insensitive searching for headers' do
	message = Message.new do
	    to "Don Werve <don.werve@gmail.com>"
	    from "MadWombat Support <support@madwombat.com>"
	    subject "Re: My wombat is all nobbly. [#33]"
	    header 'X-Test-header', "66"
	end

	message.header('X-Test-Header').should == "66"
	message.header('x-test-header').should == "66"
    end
end
