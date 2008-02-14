module Archangel
  class Site
    def initialize(name, options, configuration)
      raise ArgumentError, "`default' is a reserved site name" if name.to_s == "default"
      @name, @options, @configuration, @hostnames, @aliases, @fair = name, options, configuration, [], [], true
    end
    attr_reader :name, :options, :configuration
    attr_accessor :hostnames, :aliases, :profile_name, :fair
    attr_writer :port
    
    def watch
      upstreams.each do |upstream|
        ::God.watch do |w|
          upstream.submit(w)
        end
      end
    end
    
    def port
      @port || 80
    end
    
    def upstreams
      @upstreams ||= []
    end
    
    def profile
      @profile ||= configuration.profile_for(profile_name)
    end
    
    def root_path
      profile[:path] % name
    end
    
    def public_path
      "#{root_path}/public"
    end
    
    def load_balancer_name
      options[:on] || :nginx
    end
    
    def load_balancer
      @load_balancer ||= configuration.load_balancer_for(load_balancer_name)
    end
    
    def access_log
      load_balancer.file(:access_log) % name
    end
    
    def fair?
      fair
    end
  end
end