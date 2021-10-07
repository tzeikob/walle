# Walle

An opinionated tool to manage and configure conky for developers.

## How to install it

In order to install walle into your system you just have to execute the following command:

```sh
wget -qO - https://git.io/JaJu7 | bash
```

The walle will start automatically right after the installation process is finished. You can always start or restart the process by using the following command:

```sh
tzkb.walle start
```

or stop it like so:

```sh
tzkb.walle stop
```

## How to remove it

First of all you should stop walle if it is already running:

```sh
tzkb.walle stop
```

To remove the installation files run the following statement:

```sh
rm -rf ~/.tzkb/walle
```

Clean up both the symlink and the autostart files:

```sh
sudo rm -f /usr/local/bin/tzkb.walle
rm -f ~/.config/autostart/tzkb.walle.desktop
```

Remove the environment variables hook from the user's bashrc file:

```sh
sed -i "/source \/home\/$USER\/.tzkb\/walle\/.envrc/d" ~/.bashrc
```

Finally uninstall all conky dependencies:

```sh
sudo apt-get purge conky conky-all
```