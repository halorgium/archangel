%w( configuration configuration_builder mongrel mongrel_builder nginx nginx_builder site site_builder ).each do |f|
  require "archangel/#{f}"
end
