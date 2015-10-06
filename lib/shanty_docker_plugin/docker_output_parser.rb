require 'shanty_docker_plugin/error'
require 'shanty/logger'

module DockerPlugin
  # Methods for parsing the output from docker
  module DockerOutputParser
    extend Shanty::Logger

    def self.parse_chunk(chunk)
      parse_output(chunk) do |output|
        if output.respond_to?(:key?)
          fail output['error'] if output.key?('error')
          logger.info(output['stream']) if output.key?('stream')
        end
      end
    end

    private_class_method

    # Private: safely parse the output from docker
    #          logs a warning if the output could not be parsed
    #
    # body  - the body of the output to process
    # &block - the block to call with the parsed output
    def self.parse_output(body, &block)
      parse_output!(body, &block)
    rescue Docker::Error::UnexpectedResponseError => e
      logger.warn("Could not parse output from docker: #{e}")
      logger.warn(body)
    end

    # Private: parse the output from docker
    #
    # body  - the body of the output to process
    # block - the block to call with the parsed output
    def self.parse_output!(body, &block)
      if body.include?('}{')
        body.split('}{').each do |line|
          line = "{#{line}" unless line =~ /\A{/
          line = "#{line}}" unless line =~ /}\z/
          yield(Docker::Util.parse_json(line))
        end
      else
        body.each_line { |line| block.call(Docker::Util.parse_json(line)) }
      end
    end
  end
end
