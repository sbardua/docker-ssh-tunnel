# Reverse SSH Tunneling Web Proxy using Docker, NGINX and Let's Encrypt

A set of Docker containers for setting up an HTTPS endpoint that reverse ssh port forward's to a local port on a system behind your firewall/NAT.  Endpoint TLS certificates are automatically managed via Let's Encrypt.

# Scripted Setup

## Azure

1. Install Azure CLI 2.0 (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
    
2. Clone this repository

    ```bash
    git clone https://github.com/sbardua/tunnelingus.git
    ```

3. Run the create script, passing in the public SSH key of the local system you will be tunneling from as well as your email address for Let's Encrypt notifications (optional)

    ```bash
    ./create-azure-vm.sh "$(ssh -t user@hostname 'cat ~/.ssh/id_ed25519.pub')" 'you@example.com'
    ```

4. SSH to the remote tunnel from the local system to verify the host key and check that the public key is setup correctly

    ```bash
    ssh -p 2222 tunnelingus@your-public-fqdn.com
    ```

5. Connect to your tunnel from your local machine using autossh to ensure the tunnel stays up permanently

    ```bash
    sudo apt install autossh

    autossh -M 20000 -f -nNT -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o ConnectTimeout=5 -g -R 8080:localhost:80 -p 2222 tunnelingus@your-public-fqdn.com
    ```

6. Browsing to http://your-public-fqdn.com should redirect to HTTPS automatically with a valid TLS certificate from Let's Encrypt. BOOYA!

## AWS

TBD

# Manual Setup

1. Spin up a Linux VM in your favorite cloud

2. Install Docker and Docker Compose

    - docker (https://docs.docker.com/install/)
    - docker-compose (https://docs.docker.com/compose/install/)

3. Head over to https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion and get docker-compose-letsencrypt-nginx-proxy-companion up and running

4. Clone this repository

    ```bash
    git clone https://github.com/sbardua/tunnelingus.git
    ```

5. Make a copy of `.env.sample` and rename it to `.env`:

    Update this file with your preferences.

    ```bash
    #
    # Network
    #
    # This needs to match the value used when setting up    docker-compose-letsencrypt-nginx-proxy-companion
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

6. Add public SSH keys of the local system you will be tunneling from to the authorized_keys on the server

7. Run the start script

    ```bash
    ./start.sh
    ```

8. SSH to the remote tunnel from the local system to verify the host key and check that the public key is setup correctly

    ```bash
    ssh -p 2222 tunnelingus@your-public-fqdn.com
    ```

9. Connect to your tunnel from your local machine using autossh to ensure the tunnel stays up permanently

    ```bash
    sudo apt install autossh

    autossh -M 20000 -f -nNT -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o ConnectTimeout=5 -g -R 8080:localhost:80 -p 2222 tunnelingus@your-public-fqdn.com
    ```

## Credits

- docker-compose-letsencrypt-nginx-proxy-companion [@evertramos](https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion)
- docker-https-ssh-tunnel [@jvranish](https://github.com/jvranish/docker-https-ssh-tunnel)
- nginx-proxy [@jwilder](https://github.com/jwilder/nginx-proxy)
- docker-gen [@jwilder](https://github.com/jwilder/docker-gen)
- docker-letsencrypt-nginx-proxy-companion [@JrCs](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion)
