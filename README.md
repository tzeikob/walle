# Walle

An opinionated tool to manage and configure conky for developers.

# How to install it

In order to install walle into your system you just have to execute the following command:

```sh
wget -qO - https://git.io/JaJu7 | bash
```

# How to remove it

First of all you should stop walle if is already running:

```sh
walle stop
```

To remove the installation files run the following statements:

```sh
rm -rf ~/.tzkb/walle
rm -f ~/.config/autostart/walle.desktop
sudo rm -f /usr/local/bin/walle
```

Remove the environment variables hook from the user's bashrc file:

```sh
sed -i "/source \/home\/$USER\/.tzkb\/walle\/.envrc/d" ~/.bashrc
```

Uninstall all conky dependencies:

```sh
sudo apt-get purge conky conky-all
```