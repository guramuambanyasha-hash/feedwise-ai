#!/bin/bash

# FeedWise AI - Phase 1 Deployment Setup Script
# This script helps you set up all necessary services for deployment

set -e

echo "🚀 FeedWise AI - Phase 1 Setup"
echo "================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"

# Check Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Git installed${NC}"

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Node.js installed ($(node --version))${NC}"

# Check npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ npm installed ($(npm --version))${NC}"

echo ""
echo -e "${BLUE}Phase 1 Setup Tasks:${NC}"
echo "1. Create Vercel account & project"
echo "2. Create Google Cloud project"
echo "3. Set up Supabase"
echo "4. Create PostgreSQL database"
echo "5. Get API keys"
echo "6. Add GitHub secrets"
echo ""

# Task 1: Vercel Setup
echo -e "${YELLOW}Task 1/6: Vercel Setup${NC}"
echo "Manual steps:"
echo "1. Go to https://vercel.com/signup"
echo "2. Sign up with GitHub"
echo "3. Import this repository"
echo "4. Get your tokens from https://vercel.com/account/tokens"
echo "5. Get your Org ID from https://vercel.com/account"
read -p "Press Enter when Vercel setup is complete..."

# Task 2: Google Cloud Setup
echo ""
echo -e "${YELLOW}Task 2/6: Google Cloud Setup${NC}"

if command -v gcloud &> /dev/null; then
    echo "gcloud CLI found. Proceeding..."
    
    read -p "Enter your GCP Project ID: " GCP_PROJECT_ID
    
    echo "Creating service account..."
    gcloud iam service-accounts create feedwise-deployer \
      --display-name="FeedWise AI Deployer" \
      --project=$GCP_PROJECT_ID 2>/dev/null || echo "Service account may already exist"
    
    echo "Granting Cloud Run permissions..."
    gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
      --member=serviceAccount:feedwise-deployer@$GCP_PROJECT_ID.iam.gserviceaccount.com \
      --role=roles/run.admin 2>/dev/null || true
    
    echo "Creating service account key..."
    gcloud iam service-accounts keys create key.json \
      --iam-account=feedwise-deployer@$GCP_PROJECT_ID.iam.gserviceaccount.com \
      --project=$GCP_PROJECT_ID 2>/dev/null || echo "Key may already exist"
    
    echo -e "${GREEN}✓ GCP setup complete${NC}"
    echo "Save key.json securely. You'll need the base64 encoded version."
else
    echo -e "${YELLOW}gcloud CLI not found. Manual setup required:${NC}"
    echo "1. Go to https://console.cloud.google.com"
    echo "2. Create a new project"
    echo "3. Enable Cloud Run API"
    echo "4. Create a service account with Cloud Run admin role"
    echo "5. Create and download a JSON key"
    read -p "Press Enter when GCP setup is complete..."
fi

# Task 3: Supabase Setup
echo ""
echo -e "${YELLOW}Task 3/6: Supabase Setup${NC}"
echo "1. Go to https://supabase.com/auth/signup"
echo "2. Create a new project"
echo "3. Go to Settings → API"
echo "4. Copy your Project URL and Anon Key"
echo "5. Note your database password"
read -p "Press Enter when Supabase setup is complete..."

# Task 4: Get API Keys
echo ""
echo -e "${YELLOW}Task 4/6: Collect API Keys${NC}"

echo "Required API keys:"
echo "1. Stripe Secret Key - https://dashboard.stripe.com/apikeys"
echo "2. OpenAI API Key - https://platform.openai.com/api-keys"
echo "3. Docker Hub credentials - https://hub.docker.com/settings/security"

read -p "Press Enter when you have collected all API keys..."

# Task 5: Generate JWT Secret
echo ""
echo -e "${YELLOW}Task 5/6: Generate Secrets${NC}"

JWT_SECRET=$(openssl rand -base64 32)
echo -e "${GREEN}Generated JWT Secret:${NC}"
echo "$JWT_SECRET"
echo ""
echo "Save this JWT_SECRET - you'll need it for GitHub secrets"

# Task 6: Add GitHub Secrets
echo ""
echo -e "${YELLOW}Task 6/6: GitHub Secrets Setup${NC}"
echo ""
echo "Go to your GitHub repository:"
echo "https://github.com/guramuambanyasha-hash/feedwise-ai/settings/secrets/actions"
echo ""
echo "Add these secrets:"
echo "  VERCEL_TOKEN"
echo "  VERCEL_ORG_ID"
echo "  VERCEL_PROJECT_ID"
echo "  DOCKER_USERNAME"
echo "  DOCKER_PASSWORD"
echo "  GCP_SA_KEY (base64 encoded - cat key.json | jq -r '@base64')"
echo "  GCP_PROJECT_ID"
echo "  DATABASE_URL"
echo "  SUPABASE_URL"
echo "  SUPABASE_ANON_KEY"
echo "  STRIPE_SECRET_KEY"
echo "  OPENAI_API_KEY"
echo "  JWT_SECRET=$JWT_SECRET"
echo "  SLACK_WEBHOOK_URL (optional)"
echo ""
read -p "Press Enter when all secrets have been added to GitHub..."

# Summary
echo ""
echo -e "${GREEN}✅ Phase 1 Setup Complete!${NC}"
echo ""
echo "Summary:"
echo "✓ Vercel project created"
echo "✓ Google Cloud project configured"
echo "✓ Supabase database ready"
echo "✓ API keys collected"
echo "✓ GitHub secrets added"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Verify all GitHub secrets: gh secret list"
echo "2. Push code to main branch to trigger deployment"
echo "3. Monitor GitHub Actions: https://github.com/guramuambanyasha-hash/feedwise-ai/actions"
echo ""
echo "Continue to Phase 2: Frontend Deployment 🚀"
echo ""
