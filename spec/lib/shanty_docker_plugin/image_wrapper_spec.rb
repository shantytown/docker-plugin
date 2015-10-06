require 'spec_helper'
require 'shanty_docker_plugin/image_wrapper'
require 'docker/image'

RSpec.describe(DockerPlugin::ImageWrapper) do
  include_context('vcr')
  include_context('docker_dir')

  let(:docker_file_contents) { 'FROM ubuntu:15.10' }
  let(:image_name) { 'ubuntu' }
  subject { described_class.new(image_name, '15.10') }

  describe('.new') do
    it('can create an image wrapper with just an image name') do
      iw = described_class.new('nic')

      expect(iw.name).to eql('nic')
      expect(iw.tag).to be_nil
      expect(iw.registry).to be_nil
    end

    it('can create an image wrapper with an image name and tag') do
      iw = described_class.new('nic', 'kim')

      expect(iw.name).to eql('nic')
      expect(iw.tag).to eql('kim')
      expect(iw.registry).to be_nil
    end

    it('can create an image wrapper with just an image name') do
      iw = described_class.new('nic', 'kim', 'cage')

      expect(iw.name).to eql('nic')
      expect(iw.tag).to eql('kim')
      expect(iw.registry).to eql('cage')
    end
  end

  describe('#pull') do
    it('pulls an image', :vcr) do
      subject.pull!
      expect(subject.image).to(be_a(Docker::Image))
    end

    it('cannot pull an invalid image', :vcr) do
      expect { described_class.new('sdfdsfsf').pull! }.to(raise_error(DockerPlugin::Error::PullError))
    end
  end

  describe('#build') do
    it('builds an image', :vcr) do
      expect(subject.build(dir, DockerPlugin::DockerFile.new(dir, registry, tag, [], 'build'))).to(be_a(Docker::Image))
    end
  end

  describe('#tag') do
    it('tags an existing image', :vcr) do
      subject.add_tag!(tag)
      expect(described_class.new(image_name, tag).image.info['RepoTags']).to(include("#{image_name}:#{tag}"))
    end
  end
end
