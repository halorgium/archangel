module Archangel
  class God
    def self.watch(filename)
      configuration = Configuration.evaluate(filename)
      configuration.watch
    end
  end
end