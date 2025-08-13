#!/bin/bash

# Script to generate secure random passwords for Zulip deployment

echo "Generating secure passwords for Zulip deployment..."
echo ""
echo "# Add these to your .env file or Dokploy environment variables:"
echo ""
echo "# Django Secret Key (256-bit hex)"
echo "SECRET_KEY=$(openssl rand -hex 32)"
echo ""
echo "# PostgreSQL Password (32 characters alphanumeric)"
echo "POSTGRES_PASSWORD=$(openssl rand -base64 24 | tr -d "=+/" | cut -c1-32)"
echo ""
echo "# RabbitMQ Password (32 characters alphanumeric)"
echo "RABBITMQ_PASSWORD=$(openssl rand -base64 24 | tr -d "=+/" | cut -c1-32)"
echo ""
echo "# Keep these passwords secure and never commit them to version control!"