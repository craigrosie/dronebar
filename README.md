# dronebar

A Drone CI plugin for [BitBar](https://github.com/matryer/bitbar).

Based on work by [Christoph Schlosser](https://getbitbar.com/plugins/Dev/Drone/drone-status.1m.sh).

## Install

Copy the `dronebar.5m.sh` file to your BitBar plugins directory (make sure it's executable!)

Change the `5m` part of the filename to have the Drone build information update on a different schedule. See the [BitBar docs](https://github.com/matryer/bitbar#configure-the-refresh-time) for all the available options.

You'll need to modify a few variables in the script to get it working with your Drone CI setup.

### NAMESPACES

This variable is used to filter the repos that you will get build information for.

Set a single value to only get information about builds in one namespace:
```bash
NAMESPACES="craigrosie"
```

To get build information for repos in multiple namespaces, separate the namespaces with a `|`:
```bash
NAMESPACES="craigrosie|github"
```

### DRONE_SERVER

Set this to the url of your Drone server.

### DRONE_TOKEN

Set this to your personal Drone access token usually found at `DRONE_SERVER/account/token`.
