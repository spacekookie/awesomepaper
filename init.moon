
-- Do some import path magic :)
package.path = "?.lua;?/init.lua;" .. package.path
require 'luarocks.loader'
require 'os'
require 'io'

-- Require all the awesomewm stuff
awful = require 'awful'
naughty = require 'naughty'
gears = require 'gears'
require 'moon.all'

-- Our core module
Paper = require 'paper.paper'
PaperUtils = require 'paper.utils'

-- You need to provide your own api key (https://unsplash.com/developers)
api_key = io.open('/home/spacekookie/.config/awesome/paper/api_key', 'r')\read!
paper_screens = {}
run_delay = 3600 * 2  -- 2 hours in seconds
cache_dir = os.getenv("HOME") .. '/.cache/awesomepaper/'
print cache_dir
os.execute "mkdir -p" .. cache_dir

-- Run a function for every screen
awful.screen.connect_for_each_screen (screen) ->
  geo = screen.geometry
  naughty.notify { 
    text: "Registering a screen (#{geo.width}x#{geo.height}) for paper"
    timeout: 3
  }

  paper = Paper geo.width, geo.height, api_key
  table.insert paper_screens, { :paper, :screen }


---- Download an image and set it as the wallpaper for each screen
timer_callback = ->
  time = PaperUtils\getTime!

  for id, ps in pairs paper_screens
    path = cache_dir .. 'wallpaper_' .. id .. '_' .. time .. '.jpg'
    ps.paper\getImage(time, path)
    
    gears.wallpaper.prepare_context ps.screen
    geo = ps.screen.geometry
    print "Setting wallpaper for screen #{geo.width}x#{geo.height}" 
    gears.wallpaper.maximized path, ps.screen, true


-- Setup a timer that runs every few hours
gears.timer {
  timeout: run_delay
  autostart: true
  callback: timer_callback
}


print "Running 'timer_callback' once!"
timer_callback!
