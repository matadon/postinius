# We're only testing Address functionality.
require 'mail'
require 'mail/address'

# Set us up to use Unicode.
require 'jcode'
$KCODE = 'u'

# Make referring to Mail objects easier.
include Mail

describe(Address, '#new') do
    it "parses a address" do
        address = Address.new('Don Werve <don@madwombat.com>')
	address.name.should == 'Don Werve'
	address.address.should == 'don@madwombat.com'
    end

    it "parses an address with unicode characters" do
        address = Address.new('ドン・ワービ <don@madwombat.com>')
	address.name.should == 'ドン・ワービ'
	address.address.should == 'don@madwombat.com'
    end

    it "is eql? to an Address with the same address part" do
        one = Address.new('Don Werve <don@madwombat.com>')
        two = Address.new('ドン・ワービ <don@madwombat.com>')
	one.should.eql?(two)
    end

    it "is eql? to a string that can be parsed as an address" do
        one = Address.new('Don Werve <don@madwombat.com>')
        two = 'ドン・ワービ <don@madwombat.com>'
	one.should.eql?(two)
    end
end
