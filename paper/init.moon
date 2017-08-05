json = require 'dkjson'
https = require 'ssl.https'

import p from require 'moon.all'


-- A utility class which wraps around requests to 
-- download images for a certain resolution
class Paper
  new: (@width, @height, @key) =>



  -- Get an image for a certain keyword
  getImage: (tags) =>
    req = "https://source.unsplash.com/#{@width}x#{@height}?#{tags}"

    body, code = https.request req
    print body, code

    error code unless body 

    -- save the content to a file
    f = io.open 'image.jpg', 'wb'
    f\write body
    f\close!
