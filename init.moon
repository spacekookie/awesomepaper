
-- Do some import path magic :)
package.path = "?.lua;?/init.lua;" .. package.path
require 'luarocks.loader'
require 'os'
require 'io'

-- You need to provide your own api key (https://unsplash.com/developers)
api_key = io.read 'api.key'

Paper = require 'paper'
paper = Paper 1920, 1080, api_key

time = tonumber os.date '%H'

-- Determine (scientifically correct(ish)) what type to display
timetag = if time >= 22 or (time >= 0 and time <= 4)
  'night'
elseif time > 4 and time <= 6
  'dawn'
elseif time > 6 and time <= 12
  'morning'
elseif time > 12 and time <= 18
  'afternoon'
elseif time > 17 and time <= 19
  'dusk'
elseif time > 19 and time <= 22
  'evening'

paper\getImage timetag

-- print os.date('%H') % 4