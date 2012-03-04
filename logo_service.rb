require 'localch'
require 'sinatra/base'
require 'dragonfly'
require 'haml'

class LogoService < Sinatra::Base
  Dragonfly[:images].configure do |c|
    c.url_format = '/media/:job'
    c.log = Logger.new($stderr)
    c.datastore.configure do |d|
      d.root_path = '/Users/foz/Sites/logo_service/public/system'   # defaults to /var/tmp/dragonfly
      d.server_root = '/Users/foz/Sites/logo_service/public'       # filesystem root for serving from - default to nil
      d.store_meta = true              # default to true 
    end
  end
  
  get '/' do
    'logo service'
  end
  
  get '/search' do
    @results = Phonebook.search(
                    :what=>params[:what], 
                    :where=>params[:where],
                    :ads=>true,
                    :limit=>20,
                    :cluster=>true,
                    :api_slot=>'yellow'
                  )
    Backend::Fetcher::Hydra.run
    @app = Dragonfly[:images]    
    haml :search
  end
  
  get '/logo/:id' do |size, format|
    app.fetch_file('~/some/image.png').thumb(size).encode(format).to_response(env)
  end

end