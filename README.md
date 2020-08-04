Automation for the `acme-tiny`
==============================

[`acme-tiny`][1] is great tool to work with Let's Encrypt.
I like it. I use it.

I presume that you already had read `acme-tiny` documentation.
It's required for proper usage.

There is one big `Makefile` to generate domain private keys, CSRs, download intermediate certificates and call `acme-tiny` with proper options to finally sign the certificates.

It runs well from unprivileged user. I create special user `acme` for it.

Also there is sample configuration files and virtual host template for Apache2.


Folder structure convention
---------------------------

 - `/var/www/acme`: homedir of user `acme` (recommended mode is 0700)
   - `/var/www/acme/Makefile`: piece of magic ;)
   - `/var/www/acme/account_key.pem`: your Let's Encrypt account key
   - `/var/www/acme/domains.mk`: list of domains to serve
   - `/var/www/acme/example.com`: folder for domain-specific data (here `example.com`)
     - `/var/www/acme/example.com/private_key.pem`: domain's private key
     - `/var/www/acme/example.com/certificate.pem`: domain's signed certificate
 - `/var/www/acme-challenge`: folder to put challenge files; must be writable for `acme` user


How to use it
-------------

0. Prerequisites:
    - you have web server, like Apache2;
    - you have domain, like `example.com`;
    - your web server have real IP

1. Create user `acme` with homedir `/var/www/acme`

```sh
useradd -b /var/www -m -s /bin/bash acme
chmod 0700 /var/www/acme
```

2. Create folder `/var/www/acme-challenge`, writable to user `acme`

```sh
mkdir /var/www/acme-challenge
chmod 0775 /var/www/acme-challenge
chgrp acme /var/www/acme-challenge
```

3. Put `Makefile` (and probably other files) to `/var/www/acme`

```sh
su acme -c "cd; wget https://raw.githubusercontent.com/kastaneda/acme/master/Makefile"
```

or, if you prefer to clone this Git repo:

```sh
su acme -c "cd; git init .; git remote add -t \* -f origin https://github.com/kastaneda/acme.git; git checkout master"
```

4. Configure web server (see `apache2/acme-challenge.conf`)
5. Create and edit `domains.mk` (see `domains.mk-example`)
6. Finally, as user `acme`, at homedir, run `make`:

```sh
su acme -c "cd; make"
```


Certificate expiration
----------------------

Let's Encrypt certificates should be updated frequently.

There is special target `make expire`, it it finds certificates older than 30 days and put their timestamp to far past.
Such certificates would be renewed on next `make` run.

Note: to use new certificates, you should reload your webserver.


Multiple webservers
-------------------

TODO, FIXME: things become much more complicated if you have more than one web server.

```apache
RewriteEngine on
RewriteCond %{REQUEST_FILENAME} -f
RewriteRule (.*) - [L]
RewriteRule (.*) http://your-acme-host/.well-known/acme-challenge/$1 [L]
```

[1]: https://github.com/diafygi/acme-tiny
