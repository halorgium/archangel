require File.dirname(__FILE__) + '/../spec_helper'

module Archangel
  describe ConfigurationBuilder, "with 2 sites with the same name" do
    it "should raise an exception" do
      configuration = Configuration.new(nil)
      b = ConfigurationBuilder.new(configuration)
      b.site(:twitter) {}
      lambda {
        b.site(:twitter) {}
      }.should raise_error(ArgumentError)
    end
  end
end
