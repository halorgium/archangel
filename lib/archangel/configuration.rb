module Archangel
  class Configuration
    def self.evaluate(filename)
      c = new(filename)
      c.evaluate
      c
    end
    
    def initialize(filename)
      @filename = filename
    end
    attr_reader :filename

    def data
      @data ||= File.read(filename)
    end
    
    def evaluate
      ConfigurationBuilder.new(self).instance_eval(data, filename)
    end
    
    def log_files
      @log_files ||= {}
    end
    
    def profiles
      @profiles ||= {}
    end
    
    def profile_for(name)
      ary = profiles.find do |n,profile|
        n == name
      end
      ary && ary.last
    end
    
    def load_balancers
      @load_balancers ||= {}
    end
    
    def load_balancer_for(name)
      ary = load_balancers.find do |n,load_balancer|
        n == name
      end
      ary && ary.last
    end
    
    def upstreams
      @upstreams ||= {}
    end
    
    def upstream_for(name)
      ary = upstreams.find do |n,upstream|
        n == name
      end
      ary && ary.last
    end
    
    def sites
      @sites ||= []
    end
  end
end


