require 'base64'
require 'docker'
require 'json'
require 'uri'

module DockerPlugin
  # Public: Set up credentials from ~/.dockercfg
  class DockerCredentials
    def initialize(dockercfg_file = "#{Dir.home}/.dockercfg")
      @dockercfg_file = dockercfg_file
    end

    def auth!(registry)
      Docker.creds = find_credentials(registry)
    end

    private

    def find_credentials(registry)
      (credentials[registry] || credentials['index.docker.io'] || {}).to_h
    end

    def credentials
      @credentials ||= read_dockercfg.each_with_object({}) do |(k, v), acc|
        username, password = decode_credentials(v['auth'])
        acc[registry(k)] = { username: username, password: password, email: v['email'] }
      end
    end

    def registry(url)
      host = url
      host = URI(url).host if url.start_with?('http')
      host
    end

    def decode_credentials(base64)
      Base64.decode64(base64).split(':')
    end

    def read_dockercfg
      return {} unless File.exist?(@dockercfg_file)
      JSON.parse(File.open(@dockercfg_file, 'rb').read)
    end
  end
end
