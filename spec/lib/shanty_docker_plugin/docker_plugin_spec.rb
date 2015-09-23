require 'shanty_docker_plugin/docker_plugin'
require 'shanty_docker_plugin/image_wrapper'
require 'shanty_docker_plugin/git_tag'
require 'spec_helper'

RSpec.describe(DockerPlugin::DockerPlugin) do
  include_context('plugin')

  it('adds the docker tag automatically') do
    expect(described_class.tags).to match_array([:docker])
  end

  it('adds config for the output dir') do
    expect(described_class).to add_config(:output_dir, 'build')
  end

  it('adds config for the fall back tag') do
    expect(described_class).to add_config(:fallback_tag, 'latest')
  end

  it('adds config for the registry') do
    expect(described_class).to add_config(:registry)
  end

  it('adds config for an optional tag') do
    expect(described_class).to add_config(:tag)
  end

  it('subscribes to the build event') do
    expect(described_class).to subscribe_to(:build).with(:on_build)
  end

  it('subscribes to the deploy event') do
    expect(described_class).to subscribe_to(:deploy).with(:on_deploy)
  end

  it('finds projects by calling a method to locate the ones that have a docker file') do
    expect(described_class).to provide_projects(:resolve_projects)
  end

  let(:image_wrapper) { double('image_wrapper') }

  before do
    File.write(File.join(project_path, 'Dockerfile'), 'FROM ubuntu:15.10')
    allow(project).to receive(:path).and_return(project_paths.first)
    allow(project).to receive(:parents).and_return([])
    allow(project).to receive(:config).and_return(docker_project_name: 'one')
    allow(project).to receive(:changed?).and_return(true)
    allow(project).to receive(:all_artifacts).and_return([])
    allow(DockerPlugin::GitTag).to receive(:current_branch).and_return('master')
    allow(image_wrapper).to receive(:registry).and_return('niccage')
  end

  describe('.resolve_projects') do
    it('find docker projects in the workspace and create dependencies between them') do
      allow(file_tree).to receive(:glob).and_return([File.join(project_paths.first, 'Dockerfile'),
                                                     File.join(project_paths[1], 'Dockerfile'),
                                                     File.join(project_paths[2], 'Dockerfile')])
      File.write(File.join(project_paths[1], 'Dockerfile'), 'FROM <%= registry%>/one:master')
      File.write(File.join(project_paths[2], 'Dockerfile'), 'FROM ubuntu:15.10')
      expect(described_class.resolve_projects(env).map(&:path)).to contain_exactly(project_paths.first,
                                                                                   project_paths[1],
                                                                                   project_paths[2])
      expect(described_class.resolve_projects(env).map { |p| p.parents.map(&:path) }).to contain_exactly([],
                                                                                                         [],
                                                                                                         [project_path])
    end
  end

  describe('#on_build') do
    let(:docker_file) { double('docker_file') }

    it('can build a docker project when it has changed') do
      allow(DockerPlugin::ImageWrapper).to receive(:new).and_return(image_wrapper)
      expect(image_wrapper).to receive(:build)
      subject.on_build
    end

    it('can build when tag is set in config') do
      allow(env).to receive(:config).and_return(docker: { tag: 'nic' })
      allow(DockerPlugin::ImageWrapper).to receive(:new).and_return(image_wrapper)
      allow(DockerPlugin::DockerFile).to receive(:new).and_return(docker_file)
      expect(image_wrapper).to receive(:build).with(project_paths.first, docker_file)
      subject.on_build
    end

    it('can pull an image when it has not changed') do
      allow(project).to receive(:config).and_return(docker_project_name: 'ubuntu')
      allow(env).to receive(:config).and_return(docker: { tag: '15.10', registry: nil })
      allow(project).to receive(:changed?).and_return(false)

      expect(DockerPlugin::ImageResolutionFallback).to receive(:pull!)
      subject.on_build
    end
  end

  describe('#on_deploy') do
    let(:image) { double('image') }

    it('can push the docker image to the registry') do
      allow(DockerPlugin::ImageWrapper).to receive(:new).and_return(image_wrapper)
      allow(image_wrapper).to receive(:image).and_return(image)
      expect(image).to receive(:push)
      subject.on_deploy
    end
  end
end
