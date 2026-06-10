module Poodle
  class Application
    VERSION = ENV.fetch("GIT_TAG", "0.1.0")
  end
end
