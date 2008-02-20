module Archangel
  class Site
    def initialize(name, options, configuration)
      raise ArgumentError, "`default' is a reserved site name" if name.to_s == "default"
      @name, @options, @configuration, @hostnames, @aliases, @fair = name, options, configuration, [], [], true
    end
    attr_reader :name, :options, :configuration
    attr_accessor :hostnames, :aliases, :profile_name, :fair
    attr_writer :port, :template, :path
    
    def watch
      upstreams.each do |upstream|
        ::God.watch do |w|
          upstream.submit(w)
        end
      end
    end
    
    def port
      @port || default_port
    end
    
    def upstreams
      @upstreams ||= []
    end
    
    def profile
      @profile ||= configuration.profile_for(profile_name)
    end

    def template
      @template || "app"
    end
    
    def path
      @path || name
    end
    
    def root_path
      profile[:path] % path
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
    
    def ssl?
      false
    end
    
    def protocol
      ssl? ? "https" : "http"
    end
    
    def default_port
      ssl? ? 443 : 80
    end
    
    def default_port?
      port == default_port
    end
    
    def main_hostname
      hostnames.first.sub(/^\./, '')
    end
    
    def main_url
      url = "#{protocol}://#{main_hostname}"
      url << ":#{port}" unless default_port?
      url
    end
    
    def fair?
      fair
    end

    def render(render_attributes)
      views = {}
      attributes = render_attributes.merge(:site => self)
      views["servers/#{name}.conf"]   = @configuration.render_with("nginx/#{template}", attributes)
      views["upstreams/#{name}.conf"] = @configuration.render_with("nginx/upstream", attributes)
      views
    end
  end
end
