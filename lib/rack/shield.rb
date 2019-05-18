require 'rack'
require 'redis'

class Rack::Shield
  autoload :Configurable, 'rack/shield/configurable'
end
