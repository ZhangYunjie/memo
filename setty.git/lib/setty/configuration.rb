require 'yaml'
require 'hashie'
require 'active_support/core_ext/hash/indifferent_access'

module Setty
  class Configuration
    class LoadError < StandardError; end

    include Singleton

    class << self
      def [](key)
        instance[key]
      end

      def method_missing(name, *args)
        if instance.has_key?(name)
          self[name]
        else
          super
        end
      end
    end

    def [](key)
      load! unless @config
      @config[key]
    end

    def has_key?(key)
      load! unless @config
      @config.has_key?(key)
    end

    def method_missing(name, *args)
      if has_key?(name)
        self[name]
      else
        super
      end
    end

    def self.load!
      instance.load!
    end

    def config_path
      "#{Rails.root}/config/setty/"
    end

    def load!
      @config = Hashie::Mash.new
      Dir::glob(config_path + '*.yml').each do |file_path|
        begin
          filename = File.basename(file_path, ".*")
          @config[filename] = YAML.load(ERB.new(File.read(file_path)).result)[Rails.env]
        rescue => e
          raise LoadError, filename
        end
      end
    end
  end
end
