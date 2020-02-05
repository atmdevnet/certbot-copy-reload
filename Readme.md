# Introduction

I would like to share my idea of simplifying the update of Let's Encypt certificates in a containerized environment. My favorite web hosting platform is Docker. Therefore, to implement web applications I use Docker containers running on Linux VPS. In this environment, I have one container with a nginx proxy server to which other containers with web applications are connected. However, for the implementation of the HTTPS protocol for outdoor communication, I use free Let's Encypt certificates, which I manage using the Certbot tool. Although the described environment is undoubtedly a popular and great solution, it causes some problems.

Namely, without additional tools, I must remember to copy the certificate to the proxy server after renewing the certificate and then manually reload the website that uses the certificate. It may not be a difficult task but it requires some attention, which can be directed to more interesting activities. My idea of solving this small problem is quite simple and flexible. It allows me to completely automate the certificate update process and also allows me to avoid restarting the proxy server.

# Background

The idea is to use the Certbot timer, which is responsible for automatic and cyclical renewal of certificates. Certbot installs on the system timer service called `certbot.service`, which automatically launches the process of renewing installed certificates from time to time.

For implementation, I wrote a few simple scripts that can be freely configured. These scripts install on the system two additional services that work with the Certbot timer. The first service I named `certbot-renewed-copy.service` is responsible for automatically copying renewed certificates to the proxy directory. The second service, called `certbot-post-renewal-reload.service` deals with reloading web application containers when certificates are renewed. The proxy server container is not reloaded, this only applies to application containers.

Wherever possible, Certbot installs certificates using the webroot method, because it does not require you to disable the proxy server using port 80.

I assumed that the web application containers are managed using the Docker Compose tool. In the configuration file of this tool, for a given container (`docker-compose.yml`), the domain names corresponding to the installed certificates should be specified in the `environment: VIRTUAL_HOST` parameter.

In addition, I assume that Certbot installs the certificates in the standard directory `/etc/letsencrypt/live`.

Launched services save their logs to a standard system journal. Therefore, they can be viewed in the status of a given service or using the `journalctl` tool.

I tested this solution on Debian 9 and Ubuntu 16.04 Linux distributions.

# Using the code

Before starting the installation, copy all downloaded files into your directory of choice.

The installation procedure consists, in first, customizing the contents of configuration files and then running the script to install the services. 

In the `config.copy.cf` file, you should edit the list of certificate domains that will be copied (`certificates` field) and the destination directory path where they will be copied for the proxy server (`destination` field).

For example:

```
certificates = domain.com, sub.domain.com
destination = /path/to/proxy/certs
```

In the `config.reload.cf` file, in the `certs_path` field, enter the same path to the proxy server directory as above where the certificates will be copied:

```
certs_path = /path/to/proxy/certs
```

The `config.location.cf` file contains a list of all locations of `docker-compose.yml` files which are intended for launching containers for applications that we intend to automatically reload after certificate renewal.

For example:

```
/path/to/docked/web/app1
/path/to/docked/api2
```

To install the scripts on the system and run the services described above, I prepared a simple script called `install.sh`.

Run it this way:

```bash
$ sudo bash install.sh
```

The status and logs of installed services can be checked using these commands:

```bash
$ sudo systemctl status certbot-renewed-copy.service
$ sudo systemctl status certbot-post-renewal-reload.service
```


