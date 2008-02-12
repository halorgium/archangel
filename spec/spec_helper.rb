$:.unshift File.dirname(__FILE__) + "/../lib"
require 'rubygems'
require 'spec'
require 'archangel'

class << Archangel
  attr_accessor :fixture_path
end
Archangel.fixture_path ||= File.expand_path(File.dirname(__FILE__) + "/../fixtures")
