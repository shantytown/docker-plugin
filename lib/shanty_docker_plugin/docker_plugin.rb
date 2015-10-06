require 'shanty/plugin'
require 'shanty/project'
require 'shanty_docker_plugin/docker_credentials'
require 'shanty_docker_plugin/image_resolution_fallback'
require 'rugged'

module DockerPlugin
  # Shanty docker plugin
  class DockerPlugin < Shanty::Plugin
    NAME_OPTION = :docker_project_name
    DEPENDENCY_OPTION = :docker_dependency

    def initialize(*args)
      super(*args)
      @docker_crendentials = DockerCredentials.new
    end

    provides_config NAME_OPTION
    provides_config :registry
    provides_config :tag
    provides_config :output_dir, 'build'
    provides_config :fallback_tag, 'latest'
    subscribe :build, :on_build
    subscribe :deploy, :on_deploy
    provides_projects :resolve_projects
    description 'Discovers and builds Docker projects'

    def self.resolve_projects(env)
      project_dependencies(find_projects(env))
    end

    private_class_method

    def self.find_projects(env)
      env.file_tree.glob("**/#{DOCKER_FILE}").each_with_object({}) do |f, acc|
        project_path = File.dirname(f)
        project = find_or_create_project(project_path, env)

        project_name(project)
        project.config[DEPENDENCY_OPTION] = project_dependency(f)

        acc[project.config[NAME_OPTION]] = project
      end
    end

    def self.project_dependencies(projects)
      projects.values.each do |project|
        project.add_parent(projects[project.config[DEPENDENCY_OPTION]]) unless project.config[DEPENDENCY_OPTION].nil?
      end
    end

    def self.project_name(project)
      project.config[NAME_OPTION] = File.basename(project.path) if project.config[NAME_OPTION].empty?
    end

    def self.project_dependency(file)
      return unless (match = File.open(file, 'rb').read.match(%r{(FROM|from)\s+<%=\s*registry\s*%>/(?<name>\S+):\S+}))
      match[:name]
    end

    def on_build
      if project.changed?
        build_image
      else
        @docker_crendentials.auth!(image_wrapper.registry)
        ImageResolutionFallback.pull!(image_wrapper, config[:fallbacktag])
      end
    end

    def on_deploy
      @docker_crendentials.auth!(image_wrapper.registry)
      image_wrapper.image.push
    end

    private

    def tag
      config[:tag] || git_tag || 'latest'
    end

    def git_tag
      @git_tag ||= GitTag.current_branch(env.root)
    end

    def image_wrapper
      ImageWrapper.new(project.config[NAME_OPTION], tag, config[:registry])
    end

    def build_image
      artifacts = ParentArtifacts.copy(project, config[:output_dir])

      image_wrapper.build(project.path, docker_file(project.path, artifacts))
    end

    def docker_file(project_path, artifacts = nil)
      DockerFile.new(project_path,
                     config[:registry],
                     tag,
                     config[:output_dir],
                     artifacts)
    end
  end
end
