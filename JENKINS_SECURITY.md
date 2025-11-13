# Jenkins Security Configuration

Complete guide to enable and configure authentication in Jenkins.

## 🔐 Overview

By default, the Jenkins setup script enables basic security. This guide covers additional security configurations.

## 🚀 Quick Setup

### Option 1: Use Updated Setup Script

The `run-jenkins.sh` script now automatically enables authentication:

```bash
./run-jenkins.sh
```

This will:
- ✅ Start Jenkins with Docker support
- ✅ Enable authentication
- ✅ Show initial admin password
- ✅ Configure security settings

### Option 2: Manual Security Configuration

If you need to reconfigure security:

```bash
./configure-jenkins-security.sh
```

This will prompt for:
- Admin username (default: admin)
- Admin password (your choice)

## 📋 First Login

### Step 1: Access Jenkins

1. Open browser: `http://localhost:8090`
2. You'll see the login page (authentication is enabled!)

### Step 2: Get Initial Password

```bash
# Get the initial admin password
docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword
```

Or check the output from `run-jenkins.sh` - it displays the password.

### Step 3: Login

1. Username: `admin`
2. Password: Use the initial password from above
3. Click **"Sign in"**

### Step 4: Change Password (Recommended)

1. Click your username (top right) → **"Configure"**
2. Scroll to **"Password"** section
3. Enter new password
4. Click **"Save"**

## 🔧 Security Configuration Options

### 1. Enable/Disable Anonymous Access

**Disable anonymous access (Recommended):**

1. Go to **"Manage Jenkins"** → **"Configure Global Security"**
2. Under **"Authorization"**:
   - Select **"Logged-in users can do anything"**
   - ✅ Uncheck **"Allow anonymous read access"**
3. Click **"Save"**

**Enable anonymous read access (Not recommended):**

1. Same steps as above
2. ✅ Check **"Allow anonymous read access"**
3. Click **"Save"**

### 2. Create Additional Users

1. Go to **"Manage Jenkins"** → **"Manage Users"**
2. Click **"Create User"**
3. Fill in:
   - Username
   - Password
   - Full name
   - Email
4. Click **"Create User"**

### 3. Configure Role-Based Access

**Install Role-Based Authorization Plugin:**

1. **"Manage Jenkins"** → **"Manage Plugins"**
2. Search: **"Role-based Authorization Strategy"**
3. Install and restart

**Configure Roles:**

1. **"Manage Jenkins"** → **"Configure Global Security"**
2. Under **"Authorization"**, select **"Role-Based Strategy"**
3. Click **"Save"**
4. Go to **"Manage Jenkins"** → **"Manage and Assign Roles"**
5. Create roles:
   - **admin**: Full access
   - **developer**: Build, read
   - **viewer**: Read only

### 4. Enable CSRF Protection

1. **"Manage Jenkins"** → **"Configure Global Security"**
2. Under **"CSRF Protection"**:
   - ✅ Check **"Prevent Cross Site Request Forgery exploits"**
3. Click **"Save"**

### 5. Configure Agent-to-Master Security

1. **"Manage Jenkins"** → **"Configure Global Security"**
2. Under **"Agents"**:
   - Select **"Random"** for TCP port
   - ✅ Enable **"Agent → Master Access Control"**
3. Click **"Save"**

## 🔑 Password Management

### Reset Admin Password

If you forget the admin password:

```bash
# Stop Jenkins
docker-compose down

# Remove security configuration
docker run --rm -v jenkins_home:/var/jenkins_home alpine \
  rm -f /var/jenkins_home/config.xml

# Start Jenkins
docker-compose up -d

# Security will be disabled - reconfigure using the script
./configure-jenkins-security.sh
```

### Change Password via Script

```bash
docker exec jenkins-server bash -c "
cat > /tmp/change-password.groovy << 'EOF'
import hudson.security.*
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
def user = hudsonRealm.getUser('admin')
user.setPassword('new-password-here')
user.save()
println 'Password changed successfully'
EOF

java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ groovy /tmp/change-password.groovy
"
```

## 🛡️ Security Best Practices

### 1. Strong Passwords

- ✅ Minimum 12 characters
- ✅ Mix of uppercase, lowercase, numbers, symbols
- ✅ Unique password (not reused)
- ✅ Use password manager

### 2. Regular Updates

```bash
# Update Jenkins
docker pull jenkins/jenkins:lts
docker-compose down
docker-compose up -d

# Update plugins
# Go to: Manage Jenkins → Manage Plugins → Updates
```

### 3. Limit User Permissions

- Create separate users for different roles
- Use role-based access control
- Follow principle of least privilege
- Regularly audit user access

### 4. Enable Audit Logging

1. Install **"Audit Trail"** plugin
2. **"Manage Jenkins"** → **"Configure System"**
3. Under **"Audit Trail"**:
   - Add logger
   - Configure log location
4. Click **"Save"**

### 5. Secure Credentials

- Use Jenkins Credentials plugin
- Never hardcode passwords in Jenkinsfile
- Use environment variables
- Rotate credentials regularly

### 6. Network Security

```yaml
# docker-compose.yml - Restrict access
services:
  jenkins:
    ports:
      - "127.0.0.1:8090:8080"  # Only localhost
```

### 7. HTTPS Configuration

For production, use HTTPS:

```bash
# Generate SSL certificate
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes

# Configure Jenkins with HTTPS
# Add to docker-compose.yml:
environment:
  - JENKINS_OPTS=--httpPort=-1 --httpsPort=8443 --httpsCertificate=/cert.pem --httpsPrivateKey=/key.pem
volumes:
  - ./cert.pem:/cert.pem
  - ./key.pem:/key.pem
```

## 🔍 Security Checklist

After setup, verify:

- [ ] Authentication is enabled
- [ ] Admin password is changed from default
- [ ] Anonymous access is disabled
- [ ] CSRF protection is enabled
- [ ] Only necessary plugins are installed
- [ ] Jenkins is updated to latest version
- [ ] Credentials are stored securely
- [ ] Audit logging is enabled
- [ ] Network access is restricted
- [ ] Regular backups are configured

## 🚨 Troubleshooting

### CSRF Error (403 No valid crumb)

If you see "HTTP ERROR 403 No valid crumb was included in the request":

```bash
# Quick fix
./fix-jenkins-csrf.sh
```

This temporarily disables CSRF protection so you can login. Remember to re-enable it after:
1. Login to Jenkins
2. Go to **Manage Jenkins** → **Configure Global Security**
3. ✅ Check **"Prevent Cross Site Request Forgery exploits"**
4. Click **Save**

### Complete Reset (Fresh Start)

If Jenkins is completely broken:

```bash
# This deletes ALL data and starts fresh
./reset-jenkins.sh
```

**Warning**: This removes all jobs, configurations, and build history!

### Locked Out of Jenkins

```bash
# Disable security temporarily
docker exec jenkins-server bash -c "
sed -i 's/<useSecurity>true<\/useSecurity>/<useSecurity>false<\/useSecurity>/g' /var/jenkins_home/config.xml
"

# Restart Jenkins
docker restart jenkins-server

# Reconfigure security
./configure-jenkins-security.sh
```

### Security Realm Not Working

```bash
# Check Jenkins logs
docker logs jenkins-server

# Verify security configuration
docker exec jenkins-server cat /var/jenkins_home/config.xml | grep -A 10 "securityRealm"
```

### Cannot Create Users

1. Check security realm is configured
2. Verify you're logged in as admin
3. Check Jenkins logs for errors
4. Try restarting Jenkins

## 📊 Monitoring Security

### View Login Attempts

1. Install **"Login Theme"** plugin
2. Check logs: `docker logs jenkins-server | grep "login"`

### Audit User Actions

1. Install **"Audit Trail"** plugin
2. View logs in Jenkins UI
3. Export logs for analysis

### Check Active Sessions

1. **"Manage Jenkins"** → **"Manage Users"**
2. View active sessions
3. Terminate suspicious sessions

## 📚 Additional Resources

- [Jenkins Security Documentation](https://www.jenkins.io/doc/book/security/)
- [Securing Jenkins](https://www.jenkins.io/doc/book/security/securing-jenkins/)
- [Jenkins Hardening Guide](https://www.jenkins.io/doc/book/security/hardening/)

---

**Your Jenkins is now secure!** 🔐
