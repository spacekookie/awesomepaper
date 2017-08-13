# Awesome Paper

An awesomewm plugin that randomly sets your wallpaper to something from [unsplash](https://unsplash.com/) that corresponds to the time of day.

Right now the plugin isn't very configurable at the moment with most settings having to be set in the `paper/init.moon` file. Because awesomewm can't handle Moonscript files by default, you will need to compile them before `awesome/rc.lua` can load them. For this, there is a `Makefile` provided which has `moonc` as a dependency.

## How to install

```console
cd ~/.config/awesome/
git clone https://github.com/spacekookie/awesomepaper paper
```

You need to get your own API key for [unsplash](https://unsplash.com/developers) and set it to `api_key` in `init.moon`. You can also use the file loading mechanism provided there and store it in your awesome config directory.

Afterwards you can simply add

`require("paper")` to your `rc.lua` aaaand done :)