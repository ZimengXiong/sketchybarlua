# Packages
brew install lua
brew install switchaudio-osx
brew install nowplaying-cli

brew tap FelixKratz/formulae
brew install sketchybar

# Fonts
brew install --cask sf-symbols
brew install --cask font-sf-mono
brew install --cask font-sf-pro

cp /Users/zimengx/code/sketchybar-app-font/dist/sketchybar-app-font.ttf $HOME/Library/Fonts/sketchybar-app-font.ttf
cp /Users/zimengx/code/sketchybar-app-font/dist/icon_map.lua /Users/zimengx/.dotfiles/.config/sketchybar/helpers/app_icons.lua
# SbarLua
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)
