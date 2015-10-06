require 'erubis'
require 'fileutils'
require 'shanty/env'
require 'shanty_docker_plugin'

module DockerPlugin
  # Public: Process a dockerfile as an ERB template
  class DockerFile
    include Shanty::Logger

    attr_reader :relative_output_file, :output_file

    # Public: initialize the docker file
    #
    # base_dir  - the directory where the docker file is located
    # registry  - the docker registry to inject into the template
    # tag       - the build tag to inject into the template
    # artifacts - an array of relative paths to artifacts built by dependencies
    # build_dir - the directory to output the calculated dockerfile
    def initialize(base_dir, registry, tag, build_dir, artifacts = nil)
      @base_dir = base_dir
      @registry = registry
      @tag = tag
      @artifacts = artifacts
      @output_dir = File.join(base_dir, build_dir)
      @relative_output_file = File.join(build_dir, DOCKER_FILE)
      @output_file = File.join(base_dir, @relative_output_file)
      @docker_file = File.join(base_dir, DOCKER_FILE)
    end

    # Public: write the docker file from the template
    def write!
      FileUtils.mkdir_p(@output_dir)
      File.write(@output_file, contents)
    end

    # Public: process the contents of a docker file
    def contents
      fail("Docker file does not exist at #{@docker_file}") unless File.exist?(@docker_file)
      @contents ||= Erubis::Eruby.new(File.read(@docker_file)).result(registry: @registry,
                                                                      tag: @tag,
                                                                      artifacts: @artifacts)
    end
  end
end
