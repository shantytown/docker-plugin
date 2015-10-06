require 'fileutils'

module DockerPlugin
  # Public: methods for copying parent artifacts locally
  module ParentArtifacts
    module_function

    # Public: copy parent artifacts to the build dir
    #
    # project   - Shanty project
    # build_dir - directory under the shanty project to place
    #             parent artifacts
    #
    # Returns an array of relative paths to artifacts
    def copy(project, build_dir)
      build_path = File.join(project.path, build_dir)
      FileUtils.mkdir_p(build_path)
      artifacts = (project.all_artifacts + project.parents.flat_map(&:all_artifacts))
      copy_artifacts(artifacts, build_path, build_dir).compact
    end

    # Public copy an array of artifacts to the build dir
    #
    # artifacts  - An array of artifacts to copy
    # build_path - path under the shanty project to place
    #              parent artifacts
    # build_dir  - directory under the shanty project to place
    #              parent artifacts
    #
    # Returns an array of relative paths to artifacts
    def copy_artifacts(artifacts, build_path, build_dir)
      artifacts.map do |artifact|
        if artifact.local?
          FileUtils.cp(artifact.to_local_path, build_path)
          File.join(build_dir, File.basename(artifact.to_local_path))
        end
      end
    end
  end
end
