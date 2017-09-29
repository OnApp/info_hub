require 'active_record'
require 'onapp-utils'

# require 'custom_validators' (gem) will force us add it to all Gemfiles
require_relative '../../custom_validators/lib/custom_validators'
require_relative 'onapp/configuration' # has to be uploaded before running load hooks

module OnApp
  autoload :CentOSVersion, File.expand_path('onapp/centos_version', __dir__)

  class << self
    attr_writer :configuration
    attr_accessor :billing

    def configuration
      @configuration ||= Configuration.new
    end

    def [](*args)
      configuration.public_send(*args)
    end
    alias_method :use?, :[]

    def centos
      @centos ||= CentOSVersion.new
    end
  end

  ActiveSupport.run_load_hooks(:'onapp-configuration', self)
end
