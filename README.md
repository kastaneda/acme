Automation for the acme-tiny
============================

[`acme-tiny`][1] is great tool to work with Let's Encrypt.

Please, read `acme-tiny` documentation first.

There is one big `Makefile` to generate domain private keys, CSRs, download intermediate certificates and call `acme-tiny` with proper options to finally sign the certificates.

It runs well from unprivileged user (I create special user `acme` for this).

Also there is sample configuration files and virtual host template for Apache2.

[1]: https://github.com/diafygi/acme-tiny
