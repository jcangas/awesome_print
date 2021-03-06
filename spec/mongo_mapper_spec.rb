require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

begin
  require "mongo_mapper"
  require "ap/mixin/mongo_mapper"

  if defined?(MongoMapper)
    class User
      include MongoMapper::Document

      key :first_name, String
      key :last_name, String
    end

    describe "AwesomePrint/MongoMapper" do
      before :each do
        @ap = AwesomePrint.new(:plain => true)
      end

      it "should print for a class instance" do
        user = User.new(:first_name => "Al", :last_name => "Capone")
        out = @ap.send(:awesome, user)
        str = <<-EOS.strip
#<User:0x01234567> {
           "_id" => BSON::ObjectId('4d9183739a546f6806000001'),
     "last_name" => "Capone",
    "first_name" => "Al"
}
EOS
        out.gsub!(/'([\w]+){23}'/, "'4d9183739a546f6806000001'")
        out.gsub!(/0x([a-f\d]+)/, "0x01234567")
        out.should == str
      end

      it "should print for a class" do
        @ap.send(:awesome, User).should == <<-EOS.strip
class User < Object {
           "_id" => :object_id,
     "last_name" => :string,
    "first_name" => :string
}
EOS
      end

      it "should print for a class when type is undefined" do
        class Chamelion
          include MongoMapper::Document
          key :last_attribute
        end

        @ap.send(:awesome, Chamelion).should == <<-EOS.strip
class Chamelion < Object {
               "_id" => :object_id,
    "last_attribute" => :undefined
}
EOS
      end
    end
  end

rescue LoadError
  puts "Skipping MongoMapper specs..."
end
