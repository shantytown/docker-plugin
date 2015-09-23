require 'shanty_docker_plugin/error'
require 'shanty/logger'

module DockerPlugin
  # Methods for falling back to a different tag when resolving images
  module ImageResolutionFallback
    extend Shanty::Logger

    module_function

    def pull!(image, fallback_tag)
      image.pull!
    rescue Error::PullError
      logger.warn(
        "Could not find image #{image.name} with tag #{image.tag}, trying with #{fallback_tag}"
      )
      new_image = ImageWrapper.new(image.name, fallback_tag, image.registry)
      new_image.pull!
      new_image.add_tag!(image.tag)
    end
  end
end
