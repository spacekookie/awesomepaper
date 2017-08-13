json = require 'dkjson'
https = require 'ssl.https'

-- A utility class which wraps around requests to 
-- download images for a certain resolution
class Paper
  
  ---- Creates new Paper handle and checks the API key for validity
  new: (@width, @height, @key) =>

  ---- Get an image for a certain keyword
  getImage: (tag, filepath) =>
    error "No filename provided!" unless filepath

    req = "https://api.unsplash.com/photos/random?client_id=#{@key}&w=#{@width}&h=#{@height}&orientation=landscape&query=#{tag}"

    body, code = https.request req
    error "Failed to load image!" unless code == 200

    response = json.decode body
    custom = response['urls']['custom']
    body = https.request custom

    print "Saving file to " .. filepath

    -- save the content to a file
    f = io.open "#{filepath}", 'wb'
    f\write body
    f\close!
