json = require 'dkjson'
https = require 'ssl.https'

import p from require 'moon.all'


-- A utility class which wraps around requests to 
-- download images for a certain resolution
class Paper
  
  -- Creates new Paper handle and checks the API key for validity
  new: (@width, @height, @key) =>

  -- Get an image for a certain keyword
  getImage: (tag) =>
    -- req = "https://source.unsplash.com/#{@width}x#{@height}?#{tags}"

    req = "https://api.unsplash.com/photos/random?client_id=#{@key}&w=#{@width}&h=#{@height}&orientation=landscape&query=#{tag}"

    body = https.request req
    response = json.decode body

    custom = response['urls']['custom']
    body = https.request custom

    -- save the content to a file
    f = io.open "#{tag}.jpg", 'wb'
    f\write body
    f\close!
