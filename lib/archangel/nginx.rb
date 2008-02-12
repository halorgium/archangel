module Archangel
  class Nginx
    def initialize(configuration)
      @configuration = configuration
    end
    attr_writer :base_path, :mime_types, :pid_file, :error_log, :access_log
    attr_accessor :uid, :gid
    
    def watch
    end
    
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
  end
end