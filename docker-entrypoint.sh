#!/bin/sh

# Step 1: Copy the default aliases file
cp /aliases.orig /etc/postfix/aliases
if [ -n "$ALIASES" ]; then
  IFS=, aliases=$ALIASES
    for line in $aliases; do
        echo $line >> /etc/postfix/aliases
          done
          fi
          newaliases

# Step 2: Copy the default main.cf configuration file
cp /main.cf.orig /etc/postfix/main.cf
if [ -n "$HOSTNAME" ]; then
 echo "myhostname = $HOSTNAME" >> /etc/postfix/main.cf
fi

# Step 3: Configure SASL Authentication in Postfix
cat <<EOF >> /etc/postfix/main.cf
relayhost = [smtp.sendgrid.net]:587
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_tls_security_level = encrypt
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
EOF

# Step 4: Set up the SASL password for SendGrid
echo "[smtp.sendgrid.net]:587 apikey:$SENDGRID_API" > /etc/postfix/sasl_passwd
postmap /etc/postfix/sasl_passwd

# Step 5: Configure SASL
mkdir -p /etc/postfix/sasl
cat <<EOF > /etc/postfix/sasl/smtpd.conf
pwcheck_method: saslauthd
mech_list: plain login
EOF

# create user printers
# Add user credentials for authentication
echo "printers:s3ndgr1D" | saslpasswd2 -c -u hotmailen.com printers

# Step 6: Start SASL Authentication Daemon
saslauthd -a pam

# Step 7: Start Postfix in the foreground
postfix start-fg