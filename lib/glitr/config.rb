module Glitr

  class Config
    attr_accessor :cache_store
  end

  class << self
    attr_accessor :config
  end

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield(config)
  end

end
