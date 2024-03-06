# Description
Lightweight container providing an SVN server, based on linuxserver.io **Alpine Linux** and S6 process management (see [here](https://github.com/linuxserver/docker-baseimage-alpine) for details).
The access to the server is possible via **WebDav protocol** (http://), and via **custom protocol** (svn://).

This is based on Elle Florio's excellent svn-docker, but has been updated to from Alpine Linux
3.2 to 3.16 (the last build that supports PHP7, needed for SVNAdmin support). It has also been
adapted to use the linuxserver.io Alpine Linux base image, which has `PUID`/`PGID` support for
controlling what user Apache will run as, and use to access the repositories that are mounted
in the container.

Elle Florio provided a tutorial on how to build this image, and how to run the container on [Medium](https://medium.com/@elle.florio/the-svn-dockerization-84032e11d88d#.bafh3otmh)

# Running Commands
To run the image, you can use the following command:
```
docker run -d --name svn-server -p 80:80 -p 3690:3690 -v <hostpath>:/home/svn -v svn_config:/etc/subversion -v svnadmin_config:/opt/svnadmin/data elleflorio/svn-server
```
`/home/svn` stores your repositories and can use either bind mount or named volume. `/etc/subversion` stores subversion configuration and `/opt/svnadmin/data` stores SVNADMIN configuration and both **MUST** use named volume.

# Configuration

Apache will run with the user and group ID provided via the `PUID` and `PGID` environment variables, like all linuxserver.io based containers.

Subversion repositories are expected to be mounted at `/home/svn`, and need to be read/write accessible to the Apache user.

Access control is via the `passwd` (htpasswd format) and `subversion-access-control` file in
`/etc/subversion`. There are default empty version of these provided in the image but you
should ideally replace this configuration directory. These are read from and written to as root
so file permissions aren't overly important.

**You need to setup username and password** for the access via WebDav protocol. You can use the following command from your host machine:
```
docker exec -t svn-server htpasswd -b /etc/subversion/passwd <username> <password>
```
To verify that everything is up and running, open your browser and connect to `http://localhost/svn`. The system should ask you for the username and password, then it will show you an empty folder (no repos yet if using the stock image, or your repos if you are mounting them).
Check also that the custom protocol is working fine: go to your terminal and type `svn info svn://localhost:3690`. The system should connect to the server and tell you that is not able to find any repository.
For further information on how to configure Subversion, please refer to the [official web page](https://subversion.apache.org/).

# Alternative configuration via SVNADMIN
the image provides a graphical ui using the [SVNADMIN](https://github.com/mfreiholz/iF.SVNAdmin) interface via `http://localhost/svnadmin`.
You'll be prompted with a setup page, remember to test every step on the page then save the configuration.

# How to contribute
If you find something that can be improved or the solution to some issue, just comment the issue to notify that you will handle it, and then submit a pull request. I will then merge it and publish the updated image in the Docker Hub.
