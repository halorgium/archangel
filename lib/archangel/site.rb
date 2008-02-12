module Archangel
  class Site
    def initialize(name, options, configuration)
      @name, @options, @configuration, @hostnames = name, options, configuration, []
    end
    attr_reader :name, :options, :configuration
    attr_accessor :hostnames, :profile_name
    
    def watch
      upstreams.each do |upstream|
        ::God.watch do |w|
          upstream.submit(w)
        end
      end
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
      false
    end
    
    def no_www?
      false
    end
    
    def always_www?
      false
    end
  end
end