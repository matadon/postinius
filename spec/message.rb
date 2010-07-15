require 'postinius'
require 'postinius/message'

# Set us up to use Unicode.
require 'jcode'
$KCODE = 'u'

# Make referring to Mail objects easier.
include Postinius

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

    it "returns the body for a multipart message" do
        message = Message.new do
	    subject "A test message."
	    from "root@madwombat.com"
	    to "don@madwombat.com"

	    text "This is some text."
	    html "This is some <i>HTML</i>."
	end

	message.text.to_s.should =~ /text/
	message.html.to_s.should =~ /HTML/
    end

    it "handles foreign characters in the from address" do
	message = Message.new do
	    from "ドン・ワービ <don@madwombat.com>"
	    to "root@madwombat.com"
	    subject "こんにちは火星！"
	    text "先に送信したマニュアルでロボット探査車" \
	        + "スピリットが直れるようになると思います。"
	end
    end
end
