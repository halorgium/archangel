require File.dirname(__FILE__) + '/../spec_helper'

module Archangel
  describe "Building Mongrels with a single integer" do
    it "should return a single mongrel" do
      Mongrel.for(nil, 9000).size.should == 1
    end
    
    it "should return a mongrel with a port of 9000" do
      Mongrel.for(nil, 9000).first.port.should == 9000
    end
    
    it "should return a mongrel with the site" do
      site = mock(:site)
      Mongrel.for(site, 9000).first.site.should == site
    end
  end
  
  describe "Building Mongrels with a range" do
    it "should return a 4 mongrels" do
      Mongrel.for(nil, 9000..9003).size.should == 4
    end
    
    it "should return mongrels with ports from 9000 to 9003" do
      Mongrel.for(nil, 9000..9003).map {|m| m.port}.should == [9000, 9001, 9002, 9003]
    end
  end
end
