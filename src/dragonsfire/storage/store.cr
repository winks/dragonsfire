
module Dragonsfire

  abstract class Store
    #abstract def write
    #abstract def read
    #abstract def destroy

    def initialize(config : Hash(Symbol, String))
      @config = config
    end

    def init
    end

    def configure(k, v)
      @config[k] = v
    end
  end

end
