require 'rake/dsl_definition'

module SandthornSequelProjections
  class RakeTasks
    include Rake::DSL if defined? Rake::DSL
    def install
      namespace :sandthorn_projections do
        task :init do
          SandthornSequelProjections.start
        end
      end
    end
  end
end