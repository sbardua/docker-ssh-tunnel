## Prerequisites

In order to use this compose file (docker-compose.yml) you must have:

1. docker (https://docs.docker.com/engine/installation/)
2. docker-compose (https://docs.docker.com/compose/install/)

## How to use it

1. Spin up a Linux VM in your favorite cloud for all this goodness to live

2. Head over to https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion and get docker-compose-letsencrypt-nginx-proxy-companion up and running

3. Clone this repository:

```bash
git clone https://github.com/sbardua/docker-ssh-tunnel.git
```

4. Make a copy of `.env.sample` and rename it to `.env`:

Update this file with your preferences.

```
#
# Network
#
# This needs to match the value used when setting up docker-compose-letsencrypt-nginx-proxy-companion
NETWORK=webproxy

#
# Hostname
#
# This is the public DNS name of your server
LETSENCRYPT_HOST=example.com

#
# Email
#
LETSENCRYPT_EMAIL=you@example.com

#
# Test
#
# If true, Let's Encrypt will issue untrusted test certificates
LETSENCRYPT_TEST=false
```

5. Add public SSH keys to authorize_keys

6. Run the start script

```bash
./start.sh
```

7. Connect to your tunnel from your local machine

```bash
sudo apt install autossh

autossh -M 20000 -f -nNT -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ConnectTimeout=5 -g -R 8080:localhost:8123 -p 2222 tunnel@example.com
```

## Credits

Without the repositories below this project wouldn't be possible.

Credits goes to:
- docker-compose-letsencrypt-nginx-proxy-companion [@evertramos](https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion)
- docker-https-ssh-tunnel [@jvranish](https://github.com/jvranish/docker-https-ssh-tunnel)
- nginx-proxy [@jwilder](https://github.com/jwilder/nginx-proxy)
- docker-gen [@jwilder](https://github.com/jwilder/docker-gen)
- docker-letsencrypt-nginx-proxy-companion [@JrCs](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion)
