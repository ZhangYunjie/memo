require 'setty/version'
require 'singleton'

module Setty
  autoload :Configuration, 'setty/configuration'

  def self.config
    Configuration.instance
  end

  def self.method_missing(name, *args)
    if config.has_key?(name)
      config[name]
    else
      super
    end
  end
end
