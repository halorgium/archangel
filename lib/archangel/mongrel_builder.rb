module Archangel
  class MongrelBuilder
    def initialize(mongrel)
      @mongrel = mongrel
    end
    
    def uid(uid)
      @mongrel.uid = uid
    end

    def gid(gid)
      @mongrel.gid = gid
    end
  end
end