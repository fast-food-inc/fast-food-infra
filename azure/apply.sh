#!/bin/bash
set -e
export DB_PASS="SecurePass$(date +%s)" # Removed exclamation mark to avoid history expansion issues in some shells
echo "Using DB Pass: $DB_PASS"
terraform apply -auto-approve -var="postgres_admin_password=$DB_PASS" 2>&1 | tee apply.log
