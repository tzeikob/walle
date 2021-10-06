# Walle

An opinionated tool to manage and configure conky for developers.

# How to install it

In order to install walle into your system you just have to execute the following command:

```sh
wget -qO - https://git.io/JaJu7 | bash
```

# How to remove it

To remove the installation files along with the conky dependencies just execute the following statements:

```sh
rm -rf ~/.tzkb/walle
rm -f ~/.config/autostart/walle.desktop
sudo rm -f /usr/local/bin/walle

sudo apt-get purge conky conky-all
```