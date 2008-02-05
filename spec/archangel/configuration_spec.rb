require File.dirname(__FILE__) + '/../spec_helper'
module Archangel
  describe Configuration do
    def fixture_data(name)
      File.read(File.join(FIXTURE_PATH, "#{name}.rb"))
    end

    it "should have a filename" do
      config = Configuration.new("test.rb")
      config.filename.should == "test.rb"
    end

    it "should have data" do
      File.should_receive(:read).with("test2.rb").and_return("data")
      config = Configuration.new("test2.rb")
      config.data.should == "data"
    end

    it "should have 2 roots" do
      File.should_receive(:read).and_return(fixture_data(:config_with_2_roots))
      config = Configuration.new("2_roots")
      config.roots.size.should == 2
    end
  end
end
