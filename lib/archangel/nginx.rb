require 'fileutils'

module Archangel
  class Nginx
    def initialize(configuration)
      @configuration = configuration
    end
    attr_writer :base_path, :mime_types, :pid_file, :error_log, :access_log
    attr_accessor :uid, :gid
    
    def file(key)
      case key
      when :mime_types
        @mime_types || "#{base_path}/conf/mime.types"
      when :pid_file
        @pid_file || "#{base_path}/var/run/nginx.pid"
      when :error_log
        @error_log || "#{base_path}/var/log/nginx/error_log"
      when :access_log
        @access_log || "#{base_path}/var/log/nginx/%s.access_log"
      else
        raise IndexError, "#{key.inspect} not found"
      end
    end
    
    def base_path
      @base_path || ""
    end
    
    def error_level
      "" # "http" "debug_http"
    end
    
    def config_file
      "#{base_path}/nginx.conf"
    end
    
    def start_command
      "nginx -c #{config_file}"
    end
    
    def stop_command
      "kill `cat #{file(:pid_file)}`"
    end
    
    def restart_command
      "kill -HUP `cat #{file(:pid_file)}`"
    end
    
    def render_attributes
      {:nginx => self}
    end
    
    def render
      views = {}
      views["nginx.conf"] = @configuration.render_with('nginx/main', render_attributes)
      @configuration.sites_running_on(:nginx).each do |site|
        attributes = render_attributes.merge(:site => site)
        views["servers/#{site.name}.conf"]   = @configuration.render_with('nginx/server', attributes)
        views["upstreams/#{site.name}.conf"] = @configuration.render_with('nginx/upstream', attributes)
      end
      views
    end
    
    def write_configs(careful = true)
      render.each do |path,data|
        filename = "#{base_path}/#{path}"
        if File.exist?(filename) && careful
          $stderr.puts "> File #{filename} already exists; use -f to force"
        else
          dirname = File.dirname(filename)
          FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
          $stderr.puts "> Writing out #{filename}"
          File.open(filename, "w") do |f|
            f.write(data)
          end
        end
      end
    end
    
    def watch
      ::God.watch do |w|
        w.name = "nginx"
        w.uid = "root"
        w.gid = "wheel"
        w.pid_file = file(:pid_file)
        w.interval = 30.seconds
        w.start = start_command
        w.stop = stop_command
        w.restart = restart_command
        w.start_grace = 10.seconds
        w.restart_grace = 10.seconds

        w.behavior(:clean_pid_file)

        w.start_if do |start|
          start.condition(:process_running) do |c|
            c.interval = 5.seconds
            c.running = false
          end
        end

        w.restart_if do |restart|
          restart.condition(:memory_usage) do |c|
            c.above = 150.megabytes
            c.times = [3, 5] # 3 out of 5 intervals
          end

          restart.condition(:cpu_usage) do |c|
            c.above = 50.percent
            c.times = 5
          end
        end

        # lifecycle
        w.lifecycle do |on|
          on.condition(:flapping) do |c|
            c.to_state = [:start, :restart]
            c.times = 5
            c.within = 5.minute
            c.transition = :unmonitored
            c.retry_in = 10.minutes
            c.retry_times = 5
            c.retry_within = 2.hours
          end
        end
      end
    end
  end
end