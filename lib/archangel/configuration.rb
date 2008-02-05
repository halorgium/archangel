module Archangel
  class Configuration
    def initialize(filename)
      @filename = filename
    end
    attr_reader :filename

    def data
      @data ||= File.read(filename)
    end

    def roots
      [1, 2]
    end
  end
end


