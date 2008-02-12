module Archangel
  class NginxBuilder
    def initialize(nginx)
      @nginx = nginx
    end
    
    def uid(uid)
      @nginx.uid = uid
    end

    def gid(gid)
      @nginx.gid = gid
    end
    
    def base_path(base_path)
      @nginx.base_path = base_path
    end
    
    def mime_types(mime_types)
      @nginx.mime_types = mime_types
    end
    
    def pid_file(pid_file)
      @nginx.pid_file = pid_file
    end
    
    def error_log(error_log)
      @nginx.error_log = error_log
    end

    def access_log(access_log)
      @nginx.access_log = access_log
    end
  end
end