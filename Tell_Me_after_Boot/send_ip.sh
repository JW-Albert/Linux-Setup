#!/bin/bash

# Email configuration
SMTP_SERVER="smtp.gmail.com"
SMTP_PORT="587"
SENDER_EMAIL="jw.albert.tw@gmail.com"
SENDER_PASSWORD="cnbhqiltcgbqpvpo"  # Use App Password for Gmail
RECIPIENT_EMAIL="albert@mail.jw-albert.tw"

# Get system information
HOSTNAME=$(hostname)
IP_ADDRESS=$(hostname -I | awk '{print $1}')
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Create email content
SUBJECT="System Information: $HOSTNAME"
BODY="System Information Report
Date: $DATE
Hostname: $HOSTNAME
IP Address: $IP_ADDRESS"

# Send email using curl
echo "Subject: $SUBJECT

$BODY" | curl -s \
    --url "smtp://$SMTP_SERVER:$SMTP_PORT" \
    --mail-from "$SENDER_EMAIL" \
    --mail-rcpt "$RECIPIENT_EMAIL" \
    --ssl-reqd \
    --user "$SENDER_EMAIL:$SENDER_PASSWORD" \
    --upload-file - \
    --mail-rcpt-allowfails \
    --fail-with-body

# Check if email was sent successfully
if [ $? -eq 0 ]; then
    echo "[INFO] Email sent successfully"
else
    echo "[ERROR] Failed to send email"
fi 
