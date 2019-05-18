require 'rack'
require 'redis'

class Rack::Shield
  autoload :Configurable, 'rack/shield/configurable'
  autoload :Request, 'rack/shield/request'
end
