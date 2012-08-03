require 'sinatra/base'
require 'dragonfly'
require 'haml'
require 'localch'

class ImageService < Sinatra::Base
  SIZES={
    'tiny' => '20x20',
    'small_cropped' => '80x80#',
    'medium' => '160x160',
    'limited' => '200x200>',
    'big_square' => '400x400#',
    'large' => '260x260',
    'big' => '500x500',
    'original' => '2000x2000>'
  }

  before do
    set_vars
  end

  helpers do
    # Generates the url for the resized image.
    #   src: the binarypool resource, ex:
    #     http://bin.staticlocal.ch/info-image-ad/d2/d20f34700a2f1ede43d734673ec5fb02010c8a72/upload1.jpg
    #   size: desired size as an imagemagick spec, ex:
    #     100x200 or 50x50#
    def dragonfly_url(src, size)
      return '' if src.blank?
      path = URI.parse(src).path # make sure only the path part, no host
      url = "/images#{path}?size=#{URI.escape(size)}"
    end
  end

  get '/' do
    haml :index
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
    haml :search
  end
  
  get '/listing/:id' do
    result = Phonebook::ItemResult.get(guid: params[:id])
    @listing = result.listing
    Backend::Fetcher::Hydra.run
    haml :listing
  end

  # Dragonfly endpoint to resize any binarypool image
  #  - fetches remote image
  #  - resizes
  #  - caches and returns result
  get '/images/*' do
    path = params[:splat].first
    size = params[:size] || '100x100'
    url = "http://bin.staticlocal.ch/#{path}"
    puts "/image: #{url} size: #{size}"
    @app.fetch_url(url).thumb(size).encode('jpg').to_response(env)
  end

  def set_vars
    @app = Dragonfly[:images]
    @kind = params[:kind] || 'logo'
    @size = params[:size] || SIZES['medium']
  end

end