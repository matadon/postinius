# We're only testing Address functionality.
require 'postinius'
require 'postinius/address'

# Set us up to use Unicode.
require 'jcode'
$KCODE = 'u'

# Make referring to Mail objects easier.
include Postinius

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
        three = Address.new('Don Werve <notdon@madwombat.com>')
	one.should == two
	one.should_not == three
	two.should_not == three
    end

    it "is eql? to a string that can be parsed as an address" do
        one = Address.new('Don Werve <don@madwombat.com>')
        two = 'ドン・ワービ <don@madwombat.com>'
	three = 'don@madwombat.com'
	one.should == two
	one.should == three
    end

    it "lets you know about empty addresses" do
        one = Address.new
	one.should be_empty

        two = Address.new(nil)
	two.should be_empty

        three = Address.new("")
	three.should be_empty
    end
end
