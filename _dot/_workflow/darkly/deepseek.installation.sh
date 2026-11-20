#! /bin/bash
# 1. Install build dependencies (based on the Kubuntu dependency list provided by the official GitHub repository)
sudo apt-get update
sudo apt-get install -y -qq cmake build-essential libkf5config-dev libkdecorations3-dev \
      libqt5x11extras5-dev qtdeclarative5-dev extra-cmake-modules \
      libkf5guiaddons-dev libkf5configwidgets-dev libkf5windowsystem-dev kirigami2-dev \
      libkf5coreaddons-dev libkf5iconthemes-dev gettext qt3d5-dev libkf5kcmutils-dev \
      qt6-base-dev libkf6coreaddons-dev libkf6colorscheme-dev \
      libkf6config-dev libkf6guiaddons-dev libkf6i18n-dev libkf6iconthemes-dev \
      libkf6windowsystem-dev libkf6kcmutils-dev libkirigami-dev libkf6style-dev

# 2. Clone the Darkly repository
git clone --single-branch --depth=1 https://github.com/Bali10050/Darkly.git
cd Darkly

# 3. Run the official installation script (compile and install)
./install.sh
