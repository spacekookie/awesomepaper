require 'os'


---- Return a string according to what time it is (statically)
getTime = ->

  -- Only consider the hour
  time = tonumber os.date '%H'

  return if time >= 22 or (time >= 0 and time <= 4)
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

-- Return a table with a bunch of utility functions
return { :getTime }