# Railway Deployment Setup Guide

Complete guide to deploy your Spring Boot application to Railway with automatic GitHub Actions deployment.

## 🚂 What is Railway?

Railway is a modern deployment platform that makes it easy to deploy applications. It offers:
- Free tier with $5 credit/month
- Automatic HTTPS
- Public URL for your app
- Easy environment variables management
- GitHub integration

## 🚀 Quick Setup (5 minutes)

### Step 1: Create Railway Account

1. Go to [railway.app](https://railway.app)
2. Click **"Login"**
3. Sign in with your GitHub account
4. Authorize Railway

### Step 2: Create New Project

1. Click **"New Project"**
2. Select **"Deploy from GitHub repo"**
3. Choose `lucasalopes28/user-crud-api`
4. Railway will auto-detect your Dockerfile
5. Click **"Deploy Now"**

### Step 3: Configure Service

1. Once deployed, click on your service
2. Go to **"Settings"** tab
3. Under **"Networking"**, click **"Generate Domain"**
4. You'll get a public URL like: `https://user-crud-api-production.up.railway.app`
5. Copy this URL - your app is now live! 🎉

### Step 4: Get Railway Token (for GitHub Actions)

1. Go to [railway.app/account/tokens](https://railway.app/account/tokens)
2. Click **"Create Token"**
3. Give it a name: `GitHub Actions`
4. Copy the token (you won't see it again!)

### Step 5: Add Token to GitHub

1. Go to your GitHub repo: `https://github.com/lucasalopes28/user-crud-api`
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. Name: `RAILWAY_TOKEN`
5. Value: Paste the token from Railway
6. Click **"Add secret"**

### Step 6: Deploy!

```bash
# Commit and push the updated workflow
git add .github/workflows/ci-cd.yml RAILWAY_SETUP.md
git commit -m "Add Railway deployment"
git push origin main
```

GitHub Actions will now automatically deploy to Railway on every push to main! 🚀

## 📊 How It Works

```
Push to main → Tests → Build → Docker → Test Container → Deploy to Railway → Create Release
```

The deployment happens automatically after all tests pass and the Docker image is verified.

## 🔧 Railway Configuration

### Environment Variables

Add environment variables in Railway dashboard:

1. Go to your service
2. Click **"Variables"** tab
3. Add variables:
   - `SPRING_PROFILES_ACTIVE=prod`
   - `SERVER_PORT=8080` (Railway auto-detects this)
   - Any database URLs, API keys, etc.

### Database (Optional)

Add a PostgreSQL database:

1. In your project, click **"New"**
2. Select **"Database"** → **"PostgreSQL"**
3. Railway automatically creates connection variables
4. Update your `application.properties`:

```properties
spring.datasource.url=${DATABASE_URL}
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
```

### Custom Domain (Optional)

1. Go to **"Settings"** → **"Networking"**
2. Click **"Custom Domain"**
3. Add your domain: `api.yourdomain.com`
4. Add CNAME record in your DNS:
   - Name: `api`
   - Value: (provided by Railway)

## 🎯 Accessing Your Application

### Public URL

After deployment, your app is available at:
```
https://user-crud-api-production.up.railway.app
```

### Test Endpoints

```bash
# Health check
curl https://your-app.up.railway.app/actuator/health

# Get all users
curl https://your-app.up.railway.app/api/users

# Create a user
curl -X POST https://your-app.up.railway.app/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}'
```

## 📈 Monitoring

### View Logs

1. Go to Railway dashboard
2. Click on your service
3. Click **"Deployments"** tab
4. Click on latest deployment
5. View real-time logs

### Metrics

1. Click **"Metrics"** tab
2. View:
   - CPU usage
   - Memory usage
   - Network traffic
   - Request count

### Deployment History

1. Click **"Deployments"** tab
2. See all deployments
3. Rollback to previous version if needed

## 🔄 Deployment Options

### Option 1: Automatic (Current Setup)

Every push to `main` automatically deploys via GitHub Actions.

### Option 2: Manual via Railway Dashboard

1. Go to Railway dashboard
2. Click **"Deploy"**
3. Select branch or commit
4. Click **"Deploy"**

### Option 3: Manual via CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Link to project
railway link

# Deploy
railway up
```

## 🛠️ Troubleshooting

### Deployment Fails

**Check:**
1. Railway dashboard logs
2. GitHub Actions logs
3. Dockerfile is correct
4. Port 8080 is exposed

### App Not Responding

**Check:**
1. Service is running (Railway dashboard)
2. Domain is generated
3. Health endpoint: `/actuator/health`
4. Logs for errors

### GitHub Actions Fails

**Check:**
1. `RAILWAY_TOKEN` secret is set
2. Token is valid (not expired)
3. Service name matches in workflow

### Out of Credits

Railway free tier includes $5/month:
- Monitor usage in dashboard
- Upgrade to hobby plan ($5/month) for more
- Optimize resource usage

## 💰 Pricing

### Free Tier (Starter)
- $5 credit/month
- ~500 hours of usage
- Perfect for development/testing
- No credit card required

### Hobby Plan
- $5/month
- Unlimited usage
- Better for production
- Priority support

### Pro Plan
- $20/month
- Team features
- Advanced metrics
- SLA

## 🎨 Advanced Features

### Multiple Environments

Deploy to staging and production:

```yaml
# In .github/workflows/ci-cd.yml
deploy-staging:
  if: github.ref == 'refs/heads/develop'
  env:
    RAILWAY_SERVICE: user-crud-api-staging

deploy-production:
  if: github.ref == 'refs/heads/main'
  env:
    RAILWAY_SERVICE: user-crud-api-production
```

### Health Checks

Railway automatically monitors your app:

```yaml
# Railway will check this endpoint
/actuator/health
```

### Auto-scaling

Railway automatically scales based on traffic (Pro plan).

### Webhooks

Get notified on deployments:

1. Settings → Webhooks
2. Add webhook URL
3. Select events (deploy, crash, etc.)

## 📚 Useful Commands

```bash
# Install CLI
npm install -g @railway/cli

# Login
railway login

# Link project
railway link

# Deploy
railway up

# View logs
railway logs

# Open dashboard
railway open

# Run command in Railway environment
railway run npm start

# Add environment variable
railway variables set KEY=value

# List services
railway service list

# Switch service
railway service switch
```

## 🔐 Security Best Practices

1. **Use environment variables** for secrets
2. **Enable HTTPS** (automatic on Railway)
3. **Set CORS** properly in Spring Boot
4. **Use Railway's private networking** for databases
5. **Rotate tokens** regularly
6. **Monitor logs** for suspicious activity

## 📊 Railway vs Other Platforms

| Feature | Railway | Heroku | Render | Fly.io |
|---------|---------|--------|--------|--------|
| Free tier | $5 credit | Limited | Yes | Yes |
| Setup time | 2 min | 5 min | 5 min | 10 min |
| Auto HTTPS | Yes | Yes | Yes | Yes |
| Database | Yes | Yes | Yes | Yes |
| Docker support | Yes | Yes | Yes | Yes |
| Learning curve | Easy | Easy | Easy | Medium |

## ✅ Verification Checklist

After setup, verify:

- [ ] Railway project created
- [ ] Service deployed successfully
- [ ] Public domain generated
- [ ] App responds to requests
- [ ] `RAILWAY_TOKEN` added to GitHub
- [ ] GitHub Actions deployment works
- [ ] Logs are accessible
- [ ] Health endpoint works

## 🎯 Next Steps

1. **Add database** (PostgreSQL, MySQL, Redis)
2. **Set up monitoring** (Sentry, Datadog)
3. **Configure custom domain**
4. **Add staging environment**
5. **Set up alerts** for errors
6. **Enable auto-scaling** (Pro plan)

## 📖 Resources

- [Railway Documentation](https://docs.railway.app)
- [Railway CLI](https://docs.railway.app/develop/cli)
- [Railway Templates](https://railway.app/templates)
- [Railway Discord](https://discord.gg/railway)
- [Railway Status](https://status.railway.app)

---

**Your app is now live on Railway!** 🎉

Access it at: `https://your-app.up.railway.app`
