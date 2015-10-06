require 'spec_helper'
require 'shanty_docker_plugin/docker_file'

RSpec.describe(DockerPlugin::DockerFile) do
  include_context('docker_dir')

  let(:docker_file_contents) { 'FROM <%=registry%>/test:<%=tag%>' }
  subject { described_class.new(dir, registry, tag, [], 'build') }

  it('parses contents of dockerfile') do
    expect(subject.contents.strip).to(eql("FROM #{registry}/test:#{tag}"))
  end

  it('writes out the docker file successfully') do
    subject.write!
    expect(File.open(subject.output_file, 'rb').read.strip).to(eql("FROM #{registry}/test:#{tag}"))
  end
end
