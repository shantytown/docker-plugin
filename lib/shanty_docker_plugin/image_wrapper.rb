require 'docker'
require 'shanty_docker_plugin/error'
require 'shanty_docker_plugin/docker_output_parser'
require 'shanty/logger'

module DockerPlugin
  # Public: Provides wapper utility around Docker::Image
  class ImageWrapper
    include Shanty::Logger

    attr_reader :name, :registry, :tag

    # Public: Initialize the image wrapper
    #
    # name      - The name of the image
    # tag       - The (optional) tag of the image
    # registry  - The (optional) registry to pull the
    #             image from
    def initialize(name, tag = nil, registry = nil)
      @name = name
      @registry = registry
      @tag = tag
      if registry.nil? && tag.nil?
        no_registry_or_tag
      elsif registry.nil?
        no_registry
      else
        registry_and_tag
      end
    end

    # Public: Pull the image from the remote registry or dockerhub
    #
    # Raises an Error::PullError if the image cannot be found remotely
    def pull!
      logger.info("Pulling image #{@image_name}")
      Docker::Image.create(fromImage: @repo, tag: @tag)
      @underlying_image = lookup_image
    rescue Docker::Error::NotFoundError, Docker::Error::ArgumentError
      raise(Error::PullError, "Failed to pull image #{@long_name}")
    end

    # Public: Add a tag to the image
    #
    # new_tag - New tag String to be set on the image
    def add_tag!(new_tag)
      image.tag(repo: @repo, tag: new_tag, force: true) unless image.nil?
    end

    def image
      @underlying_image ||= lookup_image
    end

    # Public: build the docker image from a directory
    #
    # dir - the directory to use as the docker context
    #
    # Returns a Docker::Image of the build image
    def build(dir, docker_file)
      docker_file.write!

      @underlying_image = build_from_dir(dir, docker_file.relative_output_file)

      add_tag!(@tag)
      image
    end

    private

    def no_registry_or_tag
      @long_name = @name
      @image_name = @name
      @repo = @name
    end

    def no_registry
      @long_name = "#{@name}:#{@tag}"
      @image_name = @long_name
      @repo = @name
    end

    def registry_and_tag
      @long_name = "#{@registry}/#{@name}:#{@tag}"
      @image_name = "#{@name}:#{@tag}"
      @repo = "#{@registry}/#{@name}"
    end

    # Private: build a docker image from a directory
    #
    # dir             - directory to use as docker context
    # dockerfile_path - path to the docker file (built from template)
    def build_from_dir(dir, dockerfile_path)
      Docker::Image.build_from_dir(dir, dockerfile: dockerfile_path) { |c| DockerOutputParser.parse_chunk(c) }
    end

    # Private: Finds the image locally
    #
    # Returns a Docker::Image object if found or nil if missing
    def lookup_image
      images = Docker::Image.all
      images.each do |found_image|
        return found_image if (found_image.info['RepoTags'] || []).include?(@long_name)
      end
      nil
    end
  end
end
