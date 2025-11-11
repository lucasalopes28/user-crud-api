# Railway Deployment Setup

Quick guide to deploy your app to Railway via GitHub Actions.

## Step 1: Get Railway Token

1. Go to [railway.app/account/tokens](https://railway.app/account/tokens)
2. Click "Create Token"
3. Name it: `GitHub Actions`
4. Copy the token

## Step 2: Get Railway Service Name

1. Go to your Railway project dashboard
2. Look at your service name (top of the page)
3. Copy it (e.g., `user-crud-api`)

## Step 3: Add Secrets to GitHub

Go to: `https://github.com/lucasalopes28/user-crud-api/settings/secrets/actions`

Add these two secrets:

### RAILWAY_TOKEN
- Click "New repository secret"
- Name: `RAILWAY_TOKEN`
- Value: Paste the token from Step 1
- Click "Add secret"

### RAILWAY_SERVICE
- Click "New repository secret"
- Name: `RAILWAY_SERVICE`
- Value: Your service name from Step 2
- Click "Add secret"

## Step 4: Deploy

```bash
git add .github/workflows/ci-cd.yml RAILWAY_DEPLOYMENT.md
git commit -m "Add Railway deployment"
git push origin main
```

## What Happens

GitHub Actions will:
1. ✅ Run tests
2. ✅ Build JAR
3. ✅ Build Docker image
4. ✅ Test container
5. ✅ **Deploy to Railway**
6. ✅ Create release

Your app will be live at your Railway URL!

## Troubleshooting

If deployment fails:

1. **Check secrets are set**: Go to repo Settings → Secrets → Actions
2. **Verify service name**: Must match exactly in Railway dashboard
3. **Check Railway token**: Make sure it's valid and not expired
4. **View logs**: Check GitHub Actions logs for detailed error messages

## Alternative: Railway GitHub Integration

Railway can also deploy automatically without GitHub Actions:

1. Go to Railway project
2. Settings → GitHub
3. Connect your repo
4. Railway will deploy on every push to main

This is simpler but gives you less control over the deployment process.
