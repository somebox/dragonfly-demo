require 'localch'
require 'sinatra/base'
require 'dragonfly'
require 'haml'

class LogoService < Sinatra::Base

  get '/' do
    'logo service'
  end
  
  get '/search' do
    @results = Phonebook.search(
                    :what=>params[:what], 
                    :where=>params[:where],
                    :ads=>true,
                    :limit=>200,
                    :cluster=>true,
                    :api_slot=>'yellow'
                  )
    Backend::Fetcher::Hydra.run
    @app = Dragonfly[:images]    
    haml :search
  end
  

end