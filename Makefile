#
# File /var/www/acme/Makefile
#

# Here the list of domains is defined
include domains.mk

# Directory /var/www/acme-challenge
#  - must exist and be writable
#  - must be published as http://your-domain/.well-known/acme-challenge/
ACMEDIR = /var/www/acme-challenge/

# Certificate lifecycle:
# private_key.pem -> csr.pem -> certificate.pem -> fullchain.pem
DOMAIN_CERTIFICATES = $(patsubst %,%/certificate.pem,$(DOMAINS))
DOMAIN_FULLCHAINS = $(patsubst %,%/fullchain.pem,$(DOMAINS))

# https://letsencrypt.org/certificates/
CERT_CHAIN = lets-encrypt-r10.pem

# Main target: sign/renew domain certificates and do everything else
# If some cerificates is older than their CSRs, then it will be renewed
all: $(DOMAIN_CERTIFICATES) $(DOMAIN_FULLCHAINS) $(CERT_CHAIN)
.PHONY: all

# Download Let's Encrypt intermediate certificates
# See https://letsencrypt.org/certificates/
lets-encrypt-r10.pem:
	wget https://letsencrypt.org/certs/2024/r10.pem -O $@

lets-encrypt-r11.pem:
	wget https://letsencrypt.org/certs/2024/r11.pem -O $@

lets-encrypt-%.pem:
	wget https://letsencrypt.org/certs/$@

isrgrootx1.pem:
	wget https://letsencrypt.org/certs/$@

# Generate the account key
account_key.pem:
	openssl genrsa 4096 > $@

# Generate private key for the domain
%/private_key.pem:
	mkdir -p -m700 $*/
	openssl genrsa 4096 > $@

# Generate certificate signing request (CSR)
%/csr.pem: %/private_key.pem
	openssl req -new -sha256 -key $< -subj "/CN=$*" > $@

# Obtain signed certificate from Let's Encrypt by ACME protocol
%/certificate.pem: account_key.pem %/csr.pem
	acme-tiny --account-key account_key.pem --csr $*/csr.pem --acme-dir $(ACMEDIR) > $@ || rm $@

# Join signed certificate and intermediate certificates to full chain
%/fullchain.pem: %/certificate.pem $(CERT_CHAIN)
	cat $^ > $@ || rm $@

# Find certificates older than 30 days (-mtime +30) and mark them to renew
# Certificates marked to renew will be renewed on next run of `make all`
expire:
	find $(DOMAIN_CERTIFICATES) -mtime +30 | xargs -r -L1 touch -t 199912310000
.PHONY: expire

# This is needed to keep all build targets
.SECONDARY:
