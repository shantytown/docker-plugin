require 'spec_helper'
require 'shanty_docker_plugin/parent_artifacts'
require 'shanty/artifact'

RSpec.describe(DockerPlugin::ParentArtifacts) do
  include_context('tmp_dir')

  let(:artifact) { File.join(dir, 'test.txt') }
  let(:parent_artifact) { File.join(dir, 'parent.txt') }

  before(:each) do
    [parent_artifact, artifact].each do |a|
      File.open(a, 'w') { |f| f.write('test') }
    end
  end

  let(:project) { double('project') }
  let(:parent) { double('parent') }
  let(:artifacts) do
    [Shanty::Artifact.new('txt', 'test', URI("file://#{artifact}")),
     Shanty::Artifact.new('txt', 'test', URI('http://nic-cage.xyz/nic.txt'))]
  end
  let(:parent_artifacts) do
    [Shanty::Artifact.new('txt', 'test', URI("file://#{parent_artifact}")),
     Shanty::Artifact.new('txt', 'test', URI('http://nic-cage.xyz/nic.txt'))]
  end

  describe('#copy') do
    it('copies artifacts locally') do
      allow(project).to receive(:path).and_return(dir)
      allow(project).to receive(:all_artifacts).and_return(artifacts)
      allow(project).to receive(:parents).and_return([parent])

      allow(parent).to receive(:path).and_return(dir)
      allow(parent).to receive(:all_artifacts).and_return(parent_artifacts)
      allow(parent).to receive(:parents).and_return([])

      expect(
        described_class.copy(project, 'build')
      ).to match_array(['build/parent.txt', 'build/test.txt'])
    end
  end
end
