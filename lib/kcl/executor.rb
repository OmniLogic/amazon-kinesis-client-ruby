require 'tempfile'

module Kcl
  class Executor
    LOG = Logger.new STDOUT

    def initialize
      yield self

      self.class.current_executor = self
    end

    def config configuration = nil
      @configuration = Configuration.new configuration if configuration

      @configuration
    end

    def record_processor record_processor = nil
      @record_processor_callback =
        if record_processor
          proc { record_processor }
        elsif block_given?
          Proc.new
        else
          fail ArgumentError, 'RecordProcessor required'
        end
    end

    def system_properties system_properties = nil
      @system_properties = system_properties if system_properties

      @system_properties || {}
    end

    def extra_class_path *extra_class_path
      @extra_class_path = extra_class_path unless extra_class_path.empty?

      @extra_class_path || []
    end

    def run argv
      if argv[0] == 'exec'
        run_exec
      else
        run_record_processor
      end
    end

    private

    attr_reader :record_processor_callback, :configuration

    def run_exec
      command = ExecutorCommandBuilder.new(
        config_properties_path,
        system_properties: system_properties,
        extra_class_path: extra_class_path
      ).build
      LOG.info "execute command:\n#{command.join ' '}"

      system(command.join(' '))
    end

    def run_record_processor
      processor_instance = record_processor_callback.call

      processor_instance.run
    end

    def config_properties_path
      config_properties_file = Tempfile.new ['config', '.properties']
      config_properties_file.write configuration.to_properties
      config_properties_file.close
      LOG.info "properties path: #{config_properties_file.path}"
      LOG.info "properties:\n#{File.read config_properties_file.path}"

      config_properties_file.path
    end

    class << self
      attr_accessor :current_executor

      def run argv = ARGV
        fail 'Executor not configured' unless current_executor

        current_executor.run argv
      end
    end
  end
end
