json = require 'dkjson'
https = require 'ssl.https'

import p from require 'moon.all'


-- A utility class which wraps around requests to 
-- download images for a certain resolution
class Paper
  new: (@width, @height) =>

  -- Get an image for a certain keyword
  getImage: (tags) =>
    req = "https://source.unsplash.com/#{@width}x#{@height}?#{tags}"
    print req