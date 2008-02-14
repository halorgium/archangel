require File.dirname(__FILE__) + '/../spec_helper'

module ConfigurationHelpers
  def fixture_data(name)
    filename = File.join(Archangel.fixture_path, "#{name}.archangel")
    File.readlines(filename).join("\n")
  end
end

module Archangel
  describe Configuration do
    include ConfigurationHelpers
    
    it "should have a filename" do
      config = Configuration.new("test.rb")
      config.filename.should == "test.rb"
    end

    it "should have data" do
      File.should_receive(:read).with("test2.rb").and_return("data")
      config = Configuration.new("test2.rb")
      config.data.should == "data"
    end
  end
  
  describe Configuration, "for config_with_2_profiles" do
    include ConfigurationHelpers
    
    before(:each) do
      File.should_receive(:read).and_return(fixture_data(:config_with_2_profiles))
      @config = Configuration.evaluate("config_with_2_profiles")
    end
    
    it "should have the correct data" do
      @config.data.should == fixture_data(:config_with_2_profiles)
    end
    
    it "should have 2 profiles" do
      @config.profiles.size.should == 2
    end
    
    it "should have a profile called :rails" do
      @config.profiles.keys.should include(:rails)
    end
    
    it "should have a valid path for the profile called :rails" do
      @config.profiles[:rails].should == {:path => "/home/deploy/%s/current/public"}
    end
  end
  
  describe Configuration, "for single_site" do
    include ConfigurationHelpers
    
    before(:each) do
      File.should_receive(:read).and_return(fixture_data(:single_site))
      @config = Configuration.evaluate("single_site")
    end
    
    it "should have the correct data" do
      @config.data.should == fixture_data(:single_site)
    end
    
    it "should have 1 profile" do
      @config.profiles.size.should == 1
    end
    
    it "should have a profile called :rails" do
      @config.profiles.keys.should include(:rails)
    end
    
    it "should have a valid path for the profile called :rails" do
      @config.profiles[:rails].should == {:path => "/home/%s/public"}
    end
    
    it "should have a 1 site" do
      @config.sites.size.should == 1
    end
    
    it "should have a site called :twitter" do
      @config.sites.first.name.should == "twitter"
    end
    
    it "should have a site with profile_name :rails" do
      @config.sites.first.profile_name.should == :rails
    end
    
    it "should have a site with the matching profile" do
      @config.sites.first.profile.should == @config.profiles[:rails]
    end
    
    it "should have a site with a correct root_path" do
      @config.sites.first.root_path.should == "/home/twitter/public"
    end
    
    it "should have correct hostnames" do
      @config.sites.first.hostnames.should == %w(host.domain.com)
    end
  end
  
  describe Configuration, "for site_with_mongrels" do
    include ConfigurationHelpers
    
    before(:each) do
      File.should_receive(:read).and_return(fixture_data(:site_with_mongrels))
      @config = Configuration.evaluate("site_with_mongrels")
    end
    
    it "should have the correct data" do
      @config.data.should == fixture_data(:site_with_mongrels)
    end
    
    it "should have a 1 site" do
      @config.sites.size.should == 1
    end
    
    it "should have a site called :twitter" do
      @config.sites.first.name.should == "basecamp"
    end
    
    it "should be hosted on nginx" do
      @config.sites.first.load_balancer_name.should == :nginx
      @config.sites.first.load_balancer.class.should == Nginx
    end
    
    it "should have a pack of 4 mongrels" do
      @config.sites.first.upstreams.should_not be_nil
      @config.sites.first.upstreams.size.should == 4
    end
  end
  
  describe Configuration, "for site_called_default" do
    include ConfigurationHelpers
    
    it "should raise an exception" do
      File.should_receive(:read).and_return(fixture_data(:site_called_default))
      lambda {
        Configuration.evaluate("site_called_default")
      }.should raise_error(ArgumentError)
    end
  end
end
