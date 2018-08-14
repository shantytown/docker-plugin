require 'simplecov'
require 'coveralls'
require 'fileutils'
require 'logger'
require 'pathname'
require 'tmpdir'
require 'vcr'
require 'webmock'
require 'docker'

require_relative 'support/contexts/with_plugin'
require_relative 'support/contexts/with_tmp_shanty'
require_relative 'support/matchers/call_me_ruby'
require_relative 'support/matchers/plugin'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter '/spec/'
end

RSpec.configure do |config|
  config.expect_with(:rspec) do |c|
    c.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with(:rspec) do |mocks|
    mocks.verify_partial_doubles = true
  end
end

RSpec.shared_context('basics') do
  let(:name) { 'test_name' }
  let(:registry) { 'test_reg' }
  let(:tag) { 'latest' }
end

RSpec.shared_context('tmp_dir') do
  include_context('basics')

  let(:dir) { Dir.mktmpdir }

  after(:each) { FileUtils.remove_entry(dir) }
end

RSpec.shared_context('docker_dir') do
  include_context('tmp_dir')

  before(:each) do
    File.open(File.join(dir, 'Dockerfile'), 'w') { |f| f.write(docker_file_contents) }
  end
end

RSpec.shared_context('vcr') do
  include_context('basics')

  VCR.configure do |c|
    c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
    c.hook_into :webmock
    c.default_cassette_options = { record: :new_episodes }
    c.allow_http_connections_when_no_cassette = true
    c.configure_rspec_metadata!
  end
end
