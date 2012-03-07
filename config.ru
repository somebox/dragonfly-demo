require './logo_service'
require 'dragonfly'

Dragonfly[:images].configure_with(:imagemagick) do |c|
  c.url_format = '/media/:job'
  c.allow_fetch_url = true
    c.log = Logger.new($stderr)
    c.datastore.configure do |d|
      d.root_path = './public/system'   # defaults to /var/tmp/dragonfly
      d.server_root = './public'       # filesystem root for serving from - default to nil
      d.store_meta = true              # default to true 
    end
end

use Dragonfly::Middleware, :images


run LogoService