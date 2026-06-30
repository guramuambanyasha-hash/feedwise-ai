# FeedWise AI - Deployment Guide

## Production Deployment Architecture

```
GitHub Repository
       ↓
GitHub Actions (CI/CD)
       ↓
Vercel (Frontend)
Docker (Backend)
PostgreSQL (Cloud)
Supabase (Auth & Storage)
Stripe (Payments)
```

## Prerequisites

- GitHub account and repository
- Vercel account
- PostgreSQL database (RDS/Supabase)
- Supabase project
- Stripe account
- Docker installed locally
- Domain name

## Environment Setup

### 1. Supabase Setup

```bash
# Create new Supabase project
# From supabase.com dashboard

# Copy environment variables
NEXT_PUBLIC_SUPABASE_URL=your_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_KEY=your_service_key
```

### 2. Database Setup

```bash
# Create PostgreSQL database
# Using AWS RDS or Supabase

# Connection string
DATABASE_URL=postgresql://user:password@host:5432/feedwise_ai

# Run migrations
npm run db:migrate

# Seed data
npm run db:seed
```

### 3. Stripe Setup

```bash
# From stripe.com dashboard
# Get keys
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PUBLISHABLE_KEY=pk_live_...

# Create webhook endpoint
# Endpoint URL: https://yourdomain.com/api/webhooks/stripe
```

## Frontend Deployment (Vercel)

### 1. Connect GitHub Repository

```bash
# On vercel.com
# Select repository: feedwise-ai
# Select branch: main
```

### 2. Configure Build Settings

**Project settings:**
- Framework: Next.js
- Build command: `npm run build`
- Output directory: `.next`
- Install command: `npm install`

### 3. Set Environment Variables

In Vercel dashboard → Settings → Environment Variables:

```
NEXT_PUBLIC_APP_NAME=FeedWise AI
NEXT_PUBLIC_APP_URL=https://feedwise.ai
NEXT_PUBLIC_API_URL=https://api.feedwise.ai
NEXT_PUBLIC_SUPABASE_URL=your_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_key
```

### 4. Deploy

```bash
# Automatic deployment on push to main
# Or manual trigger in Vercel dashboard
```

## Backend Deployment (Docker + Cloud Run)

### 1. Create Dockerfile

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy source code
COPY . .

# Build TypeScript
RUN npm run build

# Expose port
EXPOSE 5000

# Start application
CMD ["npm", "start"]
```

### 2. Build Docker Image

```bash
docker build -t feedwise-api:latest .

# Test locally
docker run -p 5000:5000 --env-file .env.production feedwise-api:latest
```

### 3. Push to Container Registry

```bash
# Using Google Container Registry
docker tag feedwise-api:latest gcr.io/PROJECT_ID/feedwise-api:latest
docker push gcr.io/PROJECT_ID/feedwise-api:latest
```

### 4. Deploy to Cloud Run

```bash
gcloud run deploy feedwise-api \
  --image gcr.io/PROJECT_ID/feedwise-api:latest \
  --platform managed \
  --region us-central1 \
  --set-env-vars DATABASE_URL=postgresql://...,STRIPE_SECRET_KEY=sk_live_... \
  --allow-unauthenticated \
  --memory 512Mi \
  --cpu 1
```

## Alternative: Docker Compose (Self-Hosted)

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: feedwise
      POSTGRES_PASSWORD: secure_password
      POSTGRES_DB: feedwise_ai
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    environment:
      DATABASE_URL: postgresql://feedwise:secure_password@postgres:5432/feedwise_ai
      NODE_ENV: production
      PORT: 5000
    ports:
      - "5000:5000"
    depends_on:
      - postgres
    restart: always

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    environment:
      NEXT_PUBLIC_API_URL: http://backend:5000
    ports:
      - "3000:3000"
    depends_on:
      - backend
    restart: always

volumes:
  postgres_data:
```

Deploy with:
```bash
docker-compose -f docker-compose.prod.yml up -d
```

## CI/CD Pipeline (GitHub Actions)

### .github/workflows/deploy.yml

```yaml
name: Deploy

on:
  push:
    branches:
      - main

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: |
          cd frontend && npm install
          cd ../backend && npm install
      
      - name: Run tests
        run: |
          cd frontend && npm test -- --coverage
          cd ../backend && npm test -- --coverage
      
      - name: Type check
        run: |
          cd frontend && npm run type-check
          cd ../backend && npm run type-check

  deploy-frontend:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Vercel
        run: vercel deploy --prod
        env:
          VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}

  deploy-backend:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build and push Docker image
        run: |
          docker build -t gcr.io/${{ secrets.GCP_PROJECT }}/feedwise-api:${{ github.sha }} .
          docker push gcr.io/${{ secrets.GCP_PROJECT }}/feedwise-api:${{ github.sha }}
        env:
          GCP_CREDENTIALS: ${{ secrets.GCP_CREDENTIALS }}
```

## Domain & SSL

### 1. Configure Domain

```bash
# Point DNS records to:
# Vercel (frontend): feedwise.ai → vercel.com nameservers
# Backend: api.feedwise.ai → Cloud Run URL
```

### 2. SSL Certificates

- Vercel: Automatic SSL
- Cloud Run: Automatic SSL
- Self-hosted: Use Let's Encrypt with Certbot

```bash
# Certbot for self-hosted
sudo certbot certonly --standalone -d feedwise.ai
```

## Database Migrations

### Before Deployment

```bash
# Test migrations locally
npm run db:migrate

# Verify schema
psql DATABASE_URL -c "\dt"
```

### Deploy Migrations

```bash
# Run in production
gcloud run jobs create migrate \
  --image gcr.io/PROJECT_ID/feedwise-api:latest \
  --execute --command "npm run db:migrate"
```

## Monitoring & Logging

### Frontend (Vercel)

- Vercel Analytics enabled
- Real Experience Score tracking
- Error tracking via integration

### Backend

```bash
# Enable Cloud Logging
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=feedwise-api" --limit 50

# View logs
gcloud run logs read feedwise-api
```

### Database

```bash
# Monitor PostgreSQL
# Enable slow query logging
# Monitor connections and performance
```

## Backups

### Database Backups

```bash
# Automated daily backups (AWS RDS/Supabase)

# Manual backup
pg_dump DATABASE_URL > backup_$(date +%Y%m%d).sql

# Restore
psql DATABASE_URL < backup_20240630.sql
```

### File Backups

```bash
# Supabase Storage automatically handles versioning
# Daily snapshots configured in Supabase dashboard
```

## Health Checks

### Frontend Health
```bash
curl https://feedwise.ai/health

# Response:
{
  "status": "ok",
  "environment": "production"
}
```

### Backend Health
```bash
curl https://api.feedwise.ai/health

# Response:
{
  "status": "ok",
  "database": "connected",
  "cache": "connected"
}
```

## Scaling

### Auto-scaling

**Frontend (Vercel):**
- Automatic based on traffic

**Backend (Cloud Run):**
```bash
gcloud run services update feedwise-api \
  --min-instances 2 \
  --max-instances 10 \
  --concurrency 80
```

**Database (PostgreSQL):**
- Configure read replicas
- Enable connection pooling
- Monitor CPU/Memory usage

## Security Checklist

- [ ] SSL/TLS certificates configured
- [ ] Environment variables secured (no hardcoding)
- [ ] Database backups automated
- [ ] CORS properly configured
- [ ] Rate limiting enabled
- [ ] API keys rotated quarterly
- [ ] Security headers set
- [ ] DDoS protection enabled
- [ ] Regular security audits
- [ ] Dependency scanning enabled

## Rollback Procedure

```bash
# Frontend (Vercel)
vercel rollback

# Backend (Cloud Run)
gcloud run deploy feedwise-api \
  --image gcr.io/PROJECT_ID/feedwise-api:previous-tag
```

## Production Checklist

- [ ] All tests passing
- [ ] Database migrations tested
- [ ] Environment variables configured
- [ ] SSL certificates valid
- [ ] Monitoring alerts set up
- [ ] Backup tested
- [ ] Rollback plan documented
- [ ] Team trained on deployment
- [ ] Load testing completed
- [ ] Security review passed

## Support

For deployment issues:
- Check GitHub Actions logs
- Review Vercel/Cloud Run dashboards
- Consult deployment docs at https://feedwise.ai/docs
- Email: support@feedwise.ai
