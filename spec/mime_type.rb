# We're only testing Address functionality.
require 'postinius'
require 'postinius/mime_type'

# Set us up to use Unicode.
require 'jcode'
$KCODE = 'u'

# Make referring to Mail objects easier.
include Postinius

describe('MimeType') do
    it "deals with empty types" do
        type = MimeType.new
	type.should be_empty

	type = MimeType.new('text/plain')
	type.should_not be_empty
    end

    it "compares base types" do
        one = MimeType.new('text/plain; charset=us-ascii')
        two = MimeType.new('text/plain; charset=utf8')
        three = MimeType.new('text/plain')
	four = MimeType.new('text/html')

	one.should == 'text/plain'
	two.should == 'text/plain'
	three.should == 'text/plain'
	one.should == two
	one.should == three

	one.should_not == 'text/html'
	one.should_not == four
	two.should_not == four
	three.should_not == four
    end

    it "returns the character set" do
        one = MimeType.new('text/plain; charset=us-ascii')
        two = MimeType.new('text/plain; charset=utf8')
        three = MimeType.new('text/plain')

	one.charset.should == 'us-ascii'
	two.charset.should == 'utf8'
	three.charset.should be_nil
    end

    it "sets the character set" do
        type = MimeType.new('text/plain')
	type.charset.should be_nil
	type.charset = 'utf8'
	type.charset.should == 'utf8'
    end

    it "returns RFC2045 types" do
        type = MimeType.new('text/plain; charset=utf8')
	type.to_s.should be_a(String)
	type.to_s.should == 'text/plain; charset=utf8'
    end
end
