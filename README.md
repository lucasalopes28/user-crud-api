# User CRUD API

A simple REST API for managing users built with Java 21 and Spring Boot.

## Features

- Create, Read, Update, Delete (CRUD) operations for users
- User validation with email uniqueness
- In-memory H2 database
- Comprehensive unit tests
- RESTful API endpoints

## User Model

Each user has the following attributes:
- `id` (Long) - Auto-generated primary key
- `name` (String) - Required, 2-50 characters
- `email` (String) - Required, valid email format, unique
- `phone` (String) - Optional, max 15 characters
- `createdAt` (LocalDateTime) - Auto-generated
- `updatedAt` (LocalDateTime) - Auto-updated

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users` | Get all users |
| GET | `/api/users/{id}` | Get user by ID |
| POST | `/api/users` | Create new user |
| PUT | `/api/users/{id}` | Update user |
| DELETE | `/api/users/{id}` | Delete user |

## Running the Application

```bash
# Build and run
mvn spring-boot:run

# Or build jar and run
mvn clean package
java -jar target/user-crud-api-1.0.0.jar
```

The application will start on `http://localhost:8080`

## Running Tests

```bash
# Run all tests
mvn test

# Run with coverage
mvn test jacoco:report
```

## H2 Database Console

Access the H2 console at: `http://localhost:8080/h2-console`
- JDBC URL: `jdbc:h2:mem:testdb`
- Username: `sa`
- Password: (empty)

## Example Usage

### Create User
```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com","phone":"1234567890"}'
```

### Get All Users
```bash
curl http://localhost:8080/api/users
```

### Get User by ID
```bash
curl http://localhost:8080/api/users/1
```

### Update User
```bash
curl -X PUT http://localhost:8080/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"John Updated","email":"john.updated@example.com","phone":"9999999999"}'
```

### Delete User
```bash
curl -X DELETE http://localhost:8080/api/users/1
```# user-crud-api
