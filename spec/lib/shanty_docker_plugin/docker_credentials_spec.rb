require 'base64'
require 'shanty_docker_plugin/docker_credentials'

RSpec.describe(DockerPlugin::DockerCredentials) do
  let(:dockercfg) { double('dockercfg') }
  let(:registry) { 'registry.nic-cage.xyz' }
  let(:email) { 'nic@nic-cage.xyz' }
  let(:default_username) { 'kim' }
  let(:default_password) { 'coppola' }
  let(:username) { 'nic' }
  let(:password) { 'cage' }

  def credentials(username, password)
    Base64.encode64("#{username}:#{password}").delete("\n")
  end

  before do
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:open).and_return(dockercfg)
    allow(dockercfg).to receive(:read).and_return('')
    allow(JSON).to receive(:parse) do
      {
        registry => { 'auth' => credentials(username, password), 'email' => email },
        'https://index.docker.io/v1/' => { 'auth' => credentials(default_username, default_password), 'email' => email }
      }
    end
  end

  describe('#auth!') do
    it('finds a named registry entry') do
      subject.auth!(registry)

      expect(Docker.creds).to eql(username: username, password: password, email: email)
    end

    it('falls back to defaults if they exist') do
      subject.auth!('nic')

      expect(Docker.creds).to eql(username: default_username, password: default_password, email: email)
    end

    it('sets no credentials if no defaults exist') do
      allow(JSON).to receive(:parse) { {} }

      subject.auth!('cage')

      expect(Docker.creds).to be_empty
    end

    it('sets no credentials if no .dockercfg exists') do
      allow(File).to receive(:exist?).and_return(false)

      subject.auth!('cage')

      expect(Docker.creds).to be_empty
    end
  end
end
