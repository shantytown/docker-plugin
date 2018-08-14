require 'shanty_docker_plugin/docker_output_parser'
require 'spec_helper'

RSpec.describe(DockerPlugin::DockerOutputParser) do
  let(:logger) { double('logger') }

  before(:each) do
    allow(described_class).to receive(:logger).and_return(logger)
  end

  describe('#parse_chunk') do
    it('can parse a simple string as a chunk') do
      expect(logger).to receive(:warn).with(
        'Could not parse output from docker: 765: unexpected token at \'nic cage is the best\''
      )
      expect(logger).to receive(:warn).with('nic cage is the best')
      described_class.parse_chunk('nic cage is the best')
    end

    it('fails when docker daemon returns an error') do
      expect do
        described_class.parse_chunk('{ "error": "nic coppola" }')
      end.to raise_error('nic coppola')
    end

    it('parses json on a single line') do
      expect(logger).to receive(:info).with('nic cage')
      expect(logger).to receive(:info).with('is the best')
      described_class.parse_chunk('{ "stream": "nic cage" }{ "stream": "is the best" }')
    end

    it('parses json on separate lines') do
      expect(logger).to receive(:info).with('nic cage')
      expect(logger).to receive(:info).with('is the best')
      described_class.parse_chunk("{ \"stream\": \"nic cage\" }\n{ \"stream\": \"is the best\" }")
    end
  end
end
