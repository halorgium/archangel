module Archangel
  class Mongrel
    def self.for(site, enumerable_or_number)
      if enumerable_or_number.respond_to?(:to_a)
        enumerable_or_number.map do |port|
          m = new
          m.site, m.port = site, port
          m
        end
      else
        self.for(site, [enumerable_or_number])
      end
    end
    attr_accessor :site, :port
    attr_writer :uid, :gid
    
    def configuration
      site.configuration
    end
    
    def defaults
      configuration.upstreams[:mongrel]
    end
    
    def name
      "#{site_name}-mongrel-#{port}"
    end
    
    def pid_file
      "#{root_path}/tmp/pids/mongrel.#{port}.pid"
    end
    
    def log_file
      "#{root_path}/log/mongrel.#{port}.log"
    end
    
    def uid
      @uid || defaults.uid
    end
    
    def gid
      @gid || defaults.gid
    end
    
    def site_name
      "site-#{site.name}"
    end
    
    def root_path
      site.root_path
    end
    
    def start_command
      "mongrel_rails start -d -c #{root_path} -p #{port} -e production -P #{pid_file} -l #{log_file}"
    end
    
    def stop_command
      "mongrel_rails stop -P #{pid_file}"
    end
    
    def restart_command
      "mongrel_rails restart -P #{pid_file}"
    end
    
    def host_port
      "127.0.0.1:#{port}"
    end
    
    def submit(w)
      w.group = site_name
      w.name = name
      w.uid = uid
      w.gid = gid
      w.pid_file = pid_file
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