# Phase 1 Setup - Quick Start Guide

## ⚡ 5-Minute Quick Start

### What You Need
1. GitHub account (already have ✓)
2. Credit card (for cloud services)
3. 1-2 hours for setup

---

## 🚀 Step-by-Step Setup

### Step 1: Create Vercel Account (5 mins)

```bash
# Go to https://vercel.com/signup
# Sign up with GitHub
# Select your feedwise-ai repository
# Click "Import"

# Get your tokens
# Settings → Tokens → Create token
# Copy: VERCEL_TOKEN

# Account → Overview
# Copy: VERCEL_ORG_ID

# Project Settings → General
# Copy: VERCEL_PROJECT_ID
```

### Step 2: Create Google Cloud Project (10 mins)

```bash
# Go to https://console.cloud.google.com
# Create new project "feedwise-ai"
# Copy: GCP_PROJECT_ID

# Enable APIs:
# - Cloud Run
# - Cloud Logging
# - Container Registry

# Create service account:
gcloud iam service-accounts create feedwise-deployer

# Grant permissions:
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:feedwise-deployer@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/run.admin

# Create key:
gcloud iam service-accounts keys create key.json \
  --iam-account=feedwise-deployer@PROJECT_ID.iam.gserviceaccount.com

# Encode to base64:
cat key.json | jq -r '@base64'
# Copy output → GCP_SA_KEY
```

### Step 3: Create Supabase Project (10 mins)

```bash
# Go to https://supabase.com
# Create new project
# Wait for database initialization (5-10 mins)

# Settings → API:
# Copy: SUPABASE_URL
# Copy: SUPABASE_ANON_KEY

# Settings → Database → Connection string:
# Copy: DATABASE_URL
```

### Step 4: Get API Keys (5 mins)

**Stripe:**
```bash
# https://dashboard.stripe.com/apikeys
# Copy Secret Key → STRIPE_SECRET_KEY
```

**OpenAI:**
```bash
# https://platform.openai.com/api-keys
# Create key → OPENAI_API_KEY
```

**Docker Hub:**
```bash
# https://hub.docker.com/settings/security
# Create token → DOCKER_PASSWORD
# Username → DOCKER_USERNAME
```

### Step 5: Generate JWT Secret (1 min)

```bash
openssl rand -base64 32
# Output → JWT_SECRET
```

### Step 6: Add GitHub Secrets (10 mins)

```bash
# Go to https://github.com/guramuambanyasha-hash/feedwise-ai/settings/secrets/actions

# Add these 13 secrets:
# VERCEL_TOKEN
# VERCEL_ORG_ID
# VERCEL_PROJECT_ID
# DOCKER_USERNAME
# DOCKER_PASSWORD
# GCP_SA_KEY
# GCP_PROJECT_ID
# DATABASE_URL
# SUPABASE_URL
# SUPABASE_ANON_KEY
# STRIPE_SECRET_KEY
# OPENAI_API_KEY
# JWT_SECRET

# Verify:
gh secret list
```

---

## ✅ Phase 1 Complete!

When you see all 13 secrets in `gh secret list`, Phase 1 is complete.

---

## 🎯 Next: Phase 2 - Deploy

Simply push to main:

```bash
git add .
git commit -m "trigger deployment"
git push origin main
```

Watch at: https://github.com/guramuambanyasha-hash/feedwise-ai/actions

---

## 📊 Service Status Check

After setup, verify all services:

```bash
# Vercel
curl https://feedwise.ai

# Backend API
curl https://api.feedwise.ai/health

# Database
psql $DATABASE_URL -c "\dt"
```

---

## 🆘 Help

- Vercel docs: https://vercel.com/docs
- GCP docs: https://cloud.google.com/docs
- Supabase docs: https://supabase.com/docs
- Email: support@feedwise.ai

**Total time: ~1 hour** ⏱️

Now proceed to Phase 2! 🚀
