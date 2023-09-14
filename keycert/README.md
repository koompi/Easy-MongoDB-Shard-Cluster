# KeyCert

This directory create self-signed x509 certificates that is equally secured to other certificate.

## How to Run

1. Go to Each of the directories in this directory
2. Create a `.var` from the `sample.var` with all the appropriate field completed; Example has been given
3. Run the _run_ script in this directory

## Result

- It will create _Root Authority Certificate_ in `root` directory. There are 2 files: a private key and a CA file. Keep it secure because all verification and identities generation depends on it. 

- Clients certificate, when generated, can be used to connect to the server. Its configuration can be edited in `.var`. File to use for connect to server is in `cert` directory, which is created inside each of the clients configured in `.var`

- Server certificate can be generated in batch if configured in variable _SERVERS_ in `.var` in its directory. 

- After Server certificate has been generated, it will show up:
    - A directory created in its domain name in `servers` directory
    - A directory called `cert` will be generated with 2 files: one KeyCertficateFile (Example: fullchain.pem), and a Root CA (copied from the `root` directory). This `cert` must be copied to run the configuration with Docker Compose