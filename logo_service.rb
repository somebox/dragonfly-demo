require 'localch'
require 'sinatra/base'
require 'dragonfly'
require 'haml'


class LogoService < Sinatra::Base
  TYPES={
    'logo' => '50x50',
    'logo_sq' => '50x50#',
    'logo@2x' => '100x100'
  }
  
  get '/' do
    @id = params[:id] || 'hqpAytKcoekalpSM_iSp2Q'
    haml :index
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
    @kind = params[:kind] || 'logo'
    haml :search
  end
  
  get '/logo/:id/:kind.jpg' do
    # get the item
    id = Phonebook::Listing.extract_entity_id(params[:id])
    kind = params[:kind]
    result = Phonebook::ItemResult.get(guid: id)
    Backend::Fetcher::Hydra.run
    logo = result.listing.main_entry.content_ads.try(:logo)
    src = logo.image.original.location
    src = "http://bin.staticlocal.ch/#{src}" unless src.match(/^http/)

    # make rendition
    @app = Dragonfly[:images]    
    redirect @app.fetch_url(src).process(:thumb, TYPES[kind]).url
  end

end