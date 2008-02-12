require 'rubygems'
require 'archangel'

basename = File.basename(__FILE__, ".god")
archangel_file = File.dirname(__FILE__) + "/#{basename}.archangel"
Archangel::God.watch(archangel_file)