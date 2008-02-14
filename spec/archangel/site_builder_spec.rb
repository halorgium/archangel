require File.dirname(__FILE__) + '/../spec_helper'

module Archangel
  describe SiteBuilder, "with a path setting" do
    it "should have a path which is different to the name" do
      site = Site.new(nil, {}, "my_name")
      b = SiteBuilder.new(site)
      b.path "custom/path"
      site.path.should == "custom/path"
    end
  end
end
