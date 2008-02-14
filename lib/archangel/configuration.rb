require 'ostruct'
require 'erb'

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
        n.to_sym == name.to_sym
      end
      ary && ary.last
    end
    
    def upstreams
      @upstreams ||= {}
    end
    
    def upstream_for(name)
      ary = upstreams.find do |n,upstream|
        n.to_sym == name.to_sym
      end
      ary && ary.last
    end
    
    def sites
      @sites ||= []
    end
    
    def site_names
      sites.map do |s|
        s.name
      end
    end
    
    def sites_running_on(load_balancer)
      sites.select do |site|
        site.load_balancer_name == load_balancer
      end
    end
    
    def render_with(template, attributes)
      attributes = {:configuration => self}.merge(attributes)
      render_binding = OpenStruct.new(attributes).send(:binding)
      view_for(template).result(render_binding)
    end
    
    def view_for(template)
      ERB.new(File.read(view_path_for(template)), nil, ">")
    end
    
    def view_path_for(template)
       "#{view_root}/#{template}.erb"
    end
    
    def view_root
      File.dirname(__FILE__) + "/../../views"
    end
    
    def watch
      [load_balancers.values, sites].each do |collection|
        collection.each do |instance|
          instance.watch
        end
      end
    end
  end
end
