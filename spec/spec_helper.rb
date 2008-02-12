require 'rubygems'
require 'spec'
require File.dirname(__FILE__) + "/../lib/archangel"

class << Archangel
  attr_accessor :fixture_path
end
Archangel.fixture_path ||= File.expand_path(File.dirname(__FILE__) + "/../fixtures")
