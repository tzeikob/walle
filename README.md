# Walle

An opinionated tool to manage and configure conky for developers.

## How to install it

In order to install walle into your system you just download the `deb` file and run:

```sh
sudo apt-get install <path-to-deb-file>
```

Then you can start walle having the conky process spawn in the background:

```sh
walle start
```

or stop it like so:

```sh
walle stop
```

## How to remove it

To uninstall walle just execute the following command:

```sh
sudo apt-get remove walle
```

Walle comes with its dependencies, if you want to remove them too just run:

```sh
sudo apt-get autoremove
```

> Keep in mind, this will remove any other dangling dependencies your system has too.

This command will remove the conky package along with a few other dependencies.