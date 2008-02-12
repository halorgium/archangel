$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'god'

%w( configuration configuration_builder mongrel mongrel_builder nginx nginx_builder site site_builder god ).each do |f|
  require "archangel/#{f}"
end
