module Archangel
  class ConfigurationBuilder
    def initialize(configuration)
      @configuration = configuration
    end
    
    def profile(name, path)
      @configuration.profiles[name] = {:path => path}
    end
    
    def load_balancer(name, &block)
      case name
      when :nginx
        load_balancer = Nginx.new(@configuration)
        b = NginxBuilder.new(load_balancer)
        b.instance_eval(&block) if block_given?
      else
        raise IndexError, "No such load_balancer: `#{name.inspect}'"
      end
      @configuration.load_balancers[name] = load_balancer
    end
    
    def upstream(name, &block)
      case name
      when :mongrel
        upstream = Mongrel.new
        b = MongrelBuilder.new(upstream)
        b.instance_eval(&block) if block_given?
      else
        raise IndexError, "No such upstream: `#{name.inspect}'"
      end
      @configuration.upstreams[name] = upstream
    end
    
    def site(name, *args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      raise ArgumentError, "`#{name}' already has been defined" if @configuration.site_names.include?(name.to_s)
      site = Site.new(name.to_s, options, @configuration)
      b = SiteBuilder.new(site)
      b.instance_eval(&block)
      @configuration.sites << site
    end
  end
end