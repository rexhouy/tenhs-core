module Tenhs
  module Core
    class Engine < ::Rails::Engine
      isolate_namespace Tenhs::Core

      initializer "tenhs-core.assets.precompile" do |app|
        app.config.assets.precompile += %w( tenhs/core.js tenhs/vendor.js tenhs/vendor.css )
      end
    end
  end
end
