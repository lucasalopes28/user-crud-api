# Postman Collection Guide

Complete guide to use the User CRUD API Postman collection.

## Import Collection

### Option 1: Import File
1. Open Postman
2. Click **"Import"** button (top left)
3. Click **"Upload Files"**
4. Select `User-CRUD-API.postman_collection.json`
5. Click **"Import"**

### Option 2: Drag and Drop
1. Open Postman
2. Drag `User-CRUD-API.postman_collection.json` into Postman window
3. Collection is imported automatically

## Configure Environment

### Set Base URL

The collection uses a variable `{{base_url}}` that you can configure:

#### For Local Development:
1. Click on the collection name
2. Go to **"Variables"** tab
3. Set `base_url` to: `http://localhost:8080`

#### For Railway Deployment:
1. Click on the collection name
2. Go to **"Variables"** tab
3. Set `base_url` to your Railway URL: `https://your-app.up.railway.app`

### Create Environment (Optional)

For multiple environments:

1. Click **"Environments"** (left sidebar)
2. Click **"+"** to create new environment
3. Name it: `Local`
4. Add variable:
   - Variable: `base_url`
   - Initial Value: `http://localhost:8080`
   - Current Value: `http://localhost:8080`
5. Click **"Save"**

Repeat for production:
- Name: `Production`
- `base_url`: `https://your-app.up.railway.app`

## Available Requests

### 1. Health Check
- **Method**: GET
- **Endpoint**: `/actuator/health`
- **Purpose**: Verify the application is running
- **Expected Response**: 
```json
{
  "status": "UP"
}
```

### 2. Get All Users
- **Method**: GET
- **Endpoint**: `/api/users`
- **Purpose**: Retrieve all users
- **Expected Response**: Array of users

### 3. Get User by ID
- **Method**: GET
- **Endpoint**: `/api/users/1`
- **Purpose**: Retrieve specific user
- **Note**: Change the ID in the URL as needed

### 4. Create User
- **Method**: POST
- **Endpoint**: `/api/users`
- **Body**:
```json
{
  "name": "John Doe",
  "email": "john.doe@example.com"
}
```
- **Expected Response**: Created user with ID

### 5. Update User
- **Method**: PUT
- **Endpoint**: `/api/users/1`
- **Body**:
```json
{
  "name": "John Doe Updated",
  "email": "john.updated@example.com"
}
```
- **Note**: Change the ID in the URL as needed

### 6. Delete User
- **Method**: DELETE
- **Endpoint**: `/api/users/1`
- **Purpose**: Delete a user
- **Note**: Change the ID in the URL as needed

### 7. Create Multiple Users
- **Folder**: Contains 5 pre-configured requests
- **Users**: Alice, Bob, Carol, David, Emma
- **Purpose**: Quickly populate database with test data
- **Usage**: Right-click folder → "Run folder" to create all at once

## Usage Tips

### Run Single Request
1. Click on a request
2. Click **"Send"** button
3. View response in the bottom panel

### Run All Requests in Folder
1. Right-click on "Create Multiple Users" folder
2. Click **"Run folder"**
3. Click **"Run User CRUD API"**
4. All 5 users will be created

### Save Responses
1. After sending a request
2. Click **"Save Response"** (below response)
3. Add to examples for documentation

### Test Scripts (Advanced)

Add test scripts to validate responses:

```javascript
// Test for successful response
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

// Test response has expected fields
pm.test("Response has user data", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('id');
    pm.expect(jsonData).to.have.property('name');
    pm.expect(jsonData).to.have.property('email');
});
```

### Pre-request Scripts (Advanced)

Generate dynamic data:

```javascript
// Generate random email
pm.variables.set("random_email", `user${Math.floor(Math.random() * 1000)}@example.com`);

// Use in body: {{random_email}}
```

## Common Workflows

### 1. Test Complete CRUD Flow
1. Run "Health Check" - verify app is running
2. Run "Create User" - create a new user
3. Note the returned ID
4. Run "Get User by ID" - verify user exists
5. Run "Update User" - modify the user
6. Run "Get All Users" - see all users
7. Run "Delete User" - remove the user

### 2. Populate Test Data
1. Run "Health Check"
2. Right-click "Create Multiple Users" folder
3. Click "Run folder"
4. Run "Get All Users" to verify

### 3. Test Production Deployment
1. Switch environment to "Production"
2. Run "Health Check" to verify deployment
3. Run "Get All Users" to check data
4. Create test users as needed

## Troubleshooting

### Connection Refused
- **Issue**: Cannot connect to server
- **Fix**: 
  - Verify app is running: `docker ps` or check Railway dashboard
  - Check `base_url` is correct
  - For local: ensure port 8080 is not blocked

### 404 Not Found
- **Issue**: Endpoint not found
- **Fix**:
  - Verify URL path is correct
  - Check app is running on correct port
  - Review application logs

### 500 Internal Server Error
- **Issue**: Server error
- **Fix**:
  - Check application logs
  - Verify request body format
  - Ensure database is accessible

### Invalid JSON
- **Issue**: Request body is malformed
- **Fix**:
  - Verify JSON syntax in body
  - Ensure Content-Type header is set
  - Check for missing commas or quotes

## Export Collection

To share with team:

1. Right-click on collection
2. Click **"Export"**
3. Choose format: Collection v2.1
4. Save file
5. Share via Git, email, or Slack

## Generate API Documentation

1. Click on collection
2. Click **"View documentation"** (right panel)
3. Click **"Publish"**
4. Generate public documentation link
5. Share with team or clients

## Collection Runner

Run all requests automatically:

1. Click **"Runner"** (bottom left)
2. Select "User CRUD API" collection
3. Configure:
   - Iterations: 1
   - Delay: 500ms
4. Click **"Run User CRUD API"**
5. View results summary

## Monitor API (Postman Cloud)

Set up monitoring:

1. Click on collection
2. Click **"..."** → **"Monitor collection"**
3. Configure schedule (hourly, daily, etc.)
4. Get email alerts on failures
5. View uptime reports

---

**Your Postman collection is ready!** Import it and start testing your API. 🚀
