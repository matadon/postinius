require 'postinius'
require 'postinius/message'
require 'digest/md5'

# Set us up to use Unicode.
require 'jcode'
$KCODE = 'u'

# Make referring to Mail objects easier.
include Postinius

# For each of the 'it_should_parse' methods below, we define an external
# function that sets up an 'it' rspec, and then load

def it_parses(description, &block)
    it(description) do
	filename = File.join('test', 'data', 
	    description.tr(' ', '-') + ".email")
	message = Message.read(filename)
	yield(message)
    end
end

describe(Message, '#new') do
    it_parses 'simple smtp message' do |message|
	message.from.should == 'donw@madwombat.com'
	message.to.count.should == 1
	message.to.first.should == 'support@widgets.madwombat.com'
	message.subject.should == 'A Christmas Carol'
	message.body.should =~ /Marley/
    end

    it_parses 'japanese body' do |message|
	message.body.first.content_type == 'text/plain'
	message.body.first.charset == 'ISO-2022-JP'
	message.body.first.content.should =~ /冗談/
    end

    it_parses 'japanese recipient' do |message|
	message.to.first.should == 'support@madwombat.com'
	message.to.first.name.should == '佐藤 那奈'
    end

    it_parses 'japanese sender' do |message|
	message.from.should == 'donw@madwombat.com'
	message.from.name.should == '佐藤 那奈'
    end

    it_parses 'japanese subject' do |message|
        message.subject.should =~ /件名/
    end

    it_parses 'multipart mime message with attachment' do |message|
        message.body.count.should == 4
	message.files.count.should == 1
	message.files.first.size.should == 4652
	checksum = Digest::MD5.hexdigest(message.files.first.read)
	checksum.should == '99dd853c5398cd3292b2d7c743f45b1e'
	message.message_id.should =~ /\@mail\.gmail\.com\>$/
    end

    it_parses 'multipart mime with text body' do |message|
        message.body.count.should == 3
	message.body.text.should_not == nil
	message.body.text.content.empty?.should_not == true
    end
end
