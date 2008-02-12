module Archangel
  class SiteBuilder
    def initialize(site)
      @site = site
    end
    
    def hostnames(*names)
      @site.hostnames = names
    end
    
    def profile(name)
      @site.profile_name = name
    end
    
    def mongrels(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      args.each do |ports|
        Mongrel.for(@site, ports).each do |mongrel|
          @site.upstreams << mongrel
        end
      end
    end
  end
end