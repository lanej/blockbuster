require 'tmpdir'
require 'pathname'
require 'securerandom'

module Support
  class Context
    attr_reader :directory
    attr_reader :configuration

    def initialize(configuration: Blockbuster::Configuration.new)
      @configuration = configuration
    end

    def setup
      @directory = Dir.mktmpdir('blockbuster')
      configuration.test_directory = directory
    end

    def teardown
      FileUtils.rm_rf(@directory)
    end

    def cassette_file(name)
      Support::CassettePathname.new(cassette_filename(name))
    end

    def delta(time: Time.now, name: configuration.current_delta_name)
      Support::DeltaPathname.new(delta_filename(time, name))
    end

    def manager
      Blockbuster::Manager.new(configuration)
    end

    def managed(by: configuration)
      Blockbuster::Manager.new(by).tap do |manager|
        start = Time.now
        manager.rent
        yield(manager).tap do
          # account for delay in recording
          sleep [0.5 - (Time.now - start), 0].max
          manager.drop_off
        end
      end
    end

    def cassette_files
      Support::CassetteFiles.new(context: self)
    end

    def delta_files
      Support::DeltaFiles.new(context: self)
    end

    def current_deltas
      Support::DeltaPathname.new(
        File.basename(deltas.last)
      )
    end

    def cassette_filename(name)
      File.join(
        configuration.cassette_dir,
        "#{name}.yml"
      )
    end

    def delta_filename(time:, name:)
      File.join(
        configuration.delta_directory,
        "#{time.to_i}_#{name}.tar.gz"
      )
    end

    def master_archive
      Support::MainArchivePathname.new(configuration.master_tar_file_path, context: self)
    end
  end

  class CassettePathname < Pathname
    TEMPLATE = <<~YAML.freeze
      ---
      - !ruby/struct:VCR::HTTPInteraction
        request: !ruby/struct:VCR::Request
          method: :get
          uri: http://localhost:7777/example
          body:
          headers:
        response: !ruby/struct:VCR::Response
          status: !ruby/struct:VCR::ResponseStatus
            code: 200
            message: OK
          headers:
            content-type:
            - text/html;charset=utf-8
            content-length:
            - "9"
          body: %s
          http_version: "1.1"
              YAML

    def generate
      dirname.mkpath
      write(TEMPLATE % SecureRandom.base64)
      self
    end

    def regenerate
      write(TEMPLATE % SecureRandom.base64)
      self
    end
  end

  class MainArchivePathname < Pathname
    attr_reader :context

    def initialize(*args, context:)
      @context = context
      super(*args)
    end

    def generate(cassettes: 1)
      context.managed do
        cassettes.times { context.cassette_files.generate }
      end
    end
  end

  class DeltaPathname < Pathname
    def create; end
  end

  class CassetteFiles
    include Enumerable
    extend Forwardable

    attr_reader :directory
    attr_reader :context

    def_delegators :to_a, :sample

    def initialize(context:)
      @directory = Pathname.new(context.configuration.cassette_dir)
      @context = context
    end

    def generate(name: SecureRandom.uuid[0..6])
      Support::CassettePathname.new(File.join(directory, name) + '.yml').generate
    end

    def each
      return to_enum unless block_given?

      Dir[
        File.join(
          directory,
          '*.yml'
        )
      ].each do |filename|
        yield Support::CassettePathname.new(filename)
      end
    end
  end

  class DeltaFiles
    include Enumerable
    extend Forwardable

    attr_reader :directory
    attr_reader :context

    def_delegators :to_a, :sample

    def initialize(context:)
      @directory = Pathname.new(context.configuration.full_delta_directory)
      @context = context
    end

    def generate(cassettes: 1, name: SecureRandom.uuid[0..6])
      context.managed(
        by: context.configuration.clone.tap do |config|
          config.current_delta_name = name
        end
      ) do |_manager|
        context.cassette_files.sample(cassettes).each(&:regenerate)
      end
    end

    def each
      return to_enum unless block_given?

      Dir[
        File.join(
          directory,
          '*.tar.gz'
        )
      ].each do |filename|
        yield Support::DeltaPathname.new(filename)
      end
    end
  end
end
