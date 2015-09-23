require 'spec_helper'
require 'shanty_docker_plugin/git_tag'

RSpec.describe(DockerPlugin::GitTag) do
  let(:docker_file_contents) { 'FROM <%=registry%>/test:<%=tag%>' }
  subject { DockerPlugin::DockerFile.new(dir, registry, tag) }

  describe('#current_branch') do
    it('finds the current branch of a specified git root') do
      expect(described_class.current_branch(File.join(__dir__, '..', '..', '..'))).to(be_a(String))
    end

    it('fails to find the current branch on a non-git root') do
      expect(described_class.current_branch(__dir__)).to be_nil
    end

    it('fails to find the current branch on a non-existing root') do
      expect(described_class.current_branch('nic-cage')).to be_nil
    end
  end
end
