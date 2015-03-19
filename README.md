**NOTE: This app was written for local.ch to demonstrate the power of Dragonfly for use as an on-the-fly image resizing/reformatting service. Another production app was made based on this, and has been in service at local.ch for several years now, and is used by all of our web and mobile apps. So I keep it here for history.**

# Dragonfly Image Demo

This is a demonstration app using [Sinatra](http://www.sinatrarb.com) and [Dragonfly](https://github.com/markevans/dragonfly/) to serve dynamically-sized images for local.ch phonebook entries.

## What It Does

This service provides a resized version of any Binarypool image using this url scheme:

    http://img.local.ch/images/logo-ad/2b/2b9c61829e630adf4acabb3b7c8753f946059708/upload1.jpg?size=160x160#

In production, this service only really needs to know the source image path and the desired size. Because everything is generated on the fly, the service could be scaled out, partitioned (using load balancer paths or app logic), or re-deployed without any dependencies. It does not need to talk to the Rails all or query server.

## How Images are Resized

* The app reads the original image (not a rendition) from the S3 public url and resizes it on-the-fly.
* The result is cached locally, so the next request for the same image/size does not require any fetching/processing. 

The size string is an [ImageMagick Geometry String](http://www.imagemagick.org/Magick++/Geometry.html) that is passed to Dragonfly. 

The relevant code to do this is:

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

`@app` is an instance of the [Dragonfly app](http://markevans.github.com/dragonfly/file.GeneralUsage.html) in this context. Caching is provided by [Rack::Cache]() which is built in to Dragonfly.

## About the Demo

Using the [local.ch Phonebook Gem](https://github.com/local-ch/phonebook-gem) and a request to the query server, a simple search can be run. In the demo, the logos and other images are displayed, and you can resize them on the fly.

![screenshot](http://dl.dropbox.com/u/385855/Screenshots/r2xk.png)

To start the service:

    $ bundle exec rackup

Then navigate to [http://localhost:9292/](http://localhost:9292/)

## Not Implemented Yet

* There is no protection for DDOS. An HMAC solution might be sane.
* Needs error handling (maybe placeholder images for failures)
* optimization of file size: jpg compression, stripping profiles, etc.

## Storage TODO

Dragonfly needs a place to store metadata about images ("jobs") and the downloaded/uploaded originals. 

By default, this is the system's `/tmp` area (`/var/private/...` on OSX). Clearly for production, a shared folder that can be easily cleaned up (or limited) would make sense. The metadata (jobs) can be persited to S3 ([example](http://markevans.github.com/dragonfly/file.DataStorage.html#S3_datastore)), Mongo ([example](http://markevans.github.com/dragonfly/file.Mongo.html)) or [other places](http://markevans.github.com/dragonfly/file.ServingRemotely.html) instead of the filesystem.

See the [Dragonfly Data Storage docs](http://markevans.github.com/dragonfly/file.DataStorage.html) for more info.


