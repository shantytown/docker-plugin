require 'shanty/logger'
require 'rugged'

module DockerPlugin
  # Public: methods for getting the docker tag from
  #         git branch
  module GitTag
    extend Shanty::Logger

    module_function

    # Public: get the current branch from a git repo
    #
    # repo_root - the git root directory
    #
    # Returns the current branch
    def current_branch(repo_root)
      repo = Rugged::Repository.new(repo_root)
      repo.head.name.sub(%r{^refs/heads/}, '')
    rescue
      logger.debug('Could not resolve current branch')
      nil
    end
  end
end
