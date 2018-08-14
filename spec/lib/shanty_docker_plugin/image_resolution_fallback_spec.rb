require 'shanty_docker_plugin/docker_file'
require 'shanty_docker_plugin/image_resolution_fallback'
require 'spec_helper'

RSpec.describe(DockerPlugin::ImageResolutionFallback) do
  include_context('vcr')

  let(:image_name) { 'ubuntu' }
  let(:fallback_tag) { '15.10' }

  describe('#pull') do
    it('can pull an image', :vcr) do
      expect do
        described_class.pull!(DockerPlugin::ImageWrapper.new(image_name, fallback_tag), nil)
      end.to_not(raise_error)
    end

    it('can resolve a fallback dependency', :vcr) do
      expect do
        described_class.pull!(DockerPlugin::ImageWrapper.new(image_name, tag), fallback_tag)
      end.to_not(raise_error)
    end

    it('fails to resolve a non-existing tag and fallback tag', :vcr) do
      expect do
        described_class.pull!(DockerPlugin::ImageWrapper.new(image_name, "no"), "extrano")
      end.to(raise_error(DockerPlugin::Error::PullError))
    end
  end
end
