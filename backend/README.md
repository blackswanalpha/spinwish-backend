# SpinWish Backend API

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.3-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Java](https://img.shields.io/badge/Java-17-orange.svg)](https://www.oracle.com/java/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> A powerful REST API backend for SpinWish - A music request and DJ interaction platform that connects music lovers with DJs in real-time.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [API Documentation](#api-documentation)
- [Database](#database)
- [Authentication](#authentication)
- [Payment Integration](#payment-integration)
- [Project Structure](#project-structure)
- [Testing](#testing)
- [Deployment](#deployment)
- [Contributing](#contributing)

## 🎯 Overview

SpinWish Backend is a comprehensive Spring Boot application that powers the SpinWish music platform. It provides RESTful APIs for user authentication, DJ session management, song requests, real-time updates via WebSockets, and M-Pesa payment integration.

### Key Capabilities

- **User Management**: Registration, authentication, and profile management for listeners and DJs
- **Session Management**: DJs can create, manage, and track live music sessions
- **Song Requests**: Listeners can request songs and tip DJs during sessions
- **Real-time Updates**: WebSocket support for live request updates and payment notifications
- **Payment Processing**: Integrated M-Pesa STK Push for seamless mobile payments
- **File Management**: Image upload for profiles, artists, and sessions
- **Analytics**: Earnings tracking and session analytics for DJs

## ✨ Features

### Core Features

- 🔐 **JWT Authentication** - Secure token-based authentication
- 👥 **Role-Based Access Control** - Separate permissions for DJs and listeners
- 🎵 **Song Request System** - Request songs with payment integration
- 💰 **M-Pesa Integration** - Mobile money payments via Safaricom M-Pesa
- 📊 **Analytics Dashboard** - Track earnings, requests, and session metrics
- 🔔 **Real-time Notifications** - WebSocket-based live updates
- 📧 **Email Verification** - Email and SMS verification for users
- 📁 **File Upload** - Support for profile images, artist images, and session images
- 🎨 **Favorites System** - Users can favorite DJs and songs
- 📱 **RESTful API** - Clean, well-documented REST endpoints

### Advanced Features

- **Database Fallback System** - Automatic fallback from PostgreSQL to H2
- **Error Handling** - Comprehensive error handling with correlation IDs
- **Monitoring** - Prometheus metrics and health checks
- **API Documentation** - Interactive Swagger/OpenAPI documentation
- **CORS Support** - Configured for cross-origin requests
- **Compression** - Response compression for better performance

## 🛠 Tech Stack

### Core Technologies

- **Java 17** - Programming language
- **Spring Boot 3.5.3** - Application framework
- **Spring Security** - Authentication and authorization
- **Spring Data JPA** - Database access layer
- **Hibernate** - ORM framework
- **PostgreSQL** - Primary database
- **H2 Database** - Development and fallback database
- **Flyway** - Database migrations (optional)

### Libraries & Tools

- **JWT (jjwt)** - JSON Web Token implementation
- **Lombok** - Reduce boilerplate code
- **SpringDoc OpenAPI** - API documentation
- **WebSocket** - Real-time communication
- **Spring Mail** - Email functionality
- **Maven** - Build and dependency management

## 🚀 Getting Started

### Prerequisites

- Java 17 or higher
- Maven 3.6+
- PostgreSQL 12+ (optional, H2 used as fallback)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/blackswanalpha/backend.git
   cd backend
   ```

2. **Configure the application**
   
   Edit `src/main/resources/application.properties` with your settings:
   ```properties
   # Database Configuration
   spring.datasource.url=jdbc:postgresql://localhost:5432/spinwish_dev
   spring.datasource.username=your_username
   spring.datasource.password=your_password
   
   # M-Pesa Configuration
   mpesa.consumerKey=your_consumer_key
   mpesa.consumerSecret=your_consumer_secret
   mpesa.shortCode=your_shortcode
   
   # Email Configuration
   spring.mail.username=your_email@gmail.com
   spring.mail.password=your_app_password
   ```

3. **Build the project**
   ```bash
   ./mvnw clean install
   ```

4. **Run the application**
   ```bash
   ./mvnw spring-boot:run
   ```

5. **Access the application**
   - API Base URL: `http://localhost:8080`
   - Swagger UI: `http://localhost:8080/swagger-ui.html`
   - H2 Console: `http://localhost:8080/h2-console` (if using H2)

### Quick Start with Docker

```bash
# Build Docker image
docker build -t spinwish-backend .

# Run container
docker run -p 8080:8080 spinwish-backend
```

## ⚙️ Configuration

### Environment Variables

You can override configuration using environment variables:

```bash
export MPESA_CALLBACK_URL=https://your-domain.com/api/v1/payment/mpesa/callback
export SMTP_USERNAME=your_email@gmail.com
export SMTP_PASSWORD=your_app_password
```

### Database Configuration

The application supports automatic database fallback:

1. **Remote PostgreSQL** (Primary)
2. **Local PostgreSQL** (Fallback)
3. **H2 File Database** (Final fallback)

Configure in `application.properties`:

```properties
spinwish.database.fallback.enabled=true
spinwish.database.fallback.order=remote-postgres,local-postgres,h2
```

### Profiles

The application supports multiple profiles:

- `default` - Development with H2 database
- `dev` - Development with PostgreSQL
- `prod` - Production configuration
- `local` - Local development

Activate a profile:
```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

## 📚 API Documentation

### Interactive Documentation

Access the Swagger UI at: `http://localhost:8080/swagger-ui.html`

### Main API Endpoints

#### Authentication
```
POST   /api/v1/users/register          - Register new user
POST   /api/v1/users/login             - User login
POST   /api/v1/users/dj/register       - Register as DJ
POST   /api/v1/users/verify            - Verify email/phone
```

#### Sessions
```
GET    /api/v1/sessions                - Get all sessions
POST   /api/v1/sessions                - Create session (DJ only)
GET    /api/v1/sessions/{id}           - Get session details
PUT    /api/v1/sessions/{id}           - Update session
DELETE /api/v1/sessions/{id}           - Delete session
POST   /api/v1/sessions/{id}/upload-image - Upload session image
```

#### Requests
```
GET    /api/v1/requests                - Get all requests
POST   /api/v1/requests                - Create song request
PUT    /api/v1/requests/{id}/status    - Update request status
GET    /api/v1/requests/session/{id}   - Get session requests
```

#### Payments
```
POST   /api/v1/payment/mpesa/initiate  - Initiate M-Pesa payment
POST   /api/v1/payment/mpesa/callback  - M-Pesa callback (webhook)
GET    /api/v1/payment/status/{id}     - Check payment status
```

#### Songs & Artists
```
GET    /api/v1/songs                   - Get all songs
POST   /api/v1/songs                   - Add new song
GET    /api/v1/artists                 - Get all artists
POST   /api/v1/artists                 - Add new artist
```

### Postman Collection

Import the Postman collection: `SpinWish.postman_collection.json`

## 🗄️ Database

### Schema Overview

Main entities:
- **Users** - User accounts (listeners and DJs)
- **Roles** - User roles and permissions
- **Profile** - Extended user profile information
- **Session** - DJ music sessions
- **Request** - Song requests from listeners
- **Songs** - Song catalog
- **Artists** - Artist information
- **Payments** - Payment transactions
- **UserFavorites** - User favorite DJs and songs

### Database Migrations

Flyway migrations are located in `src/main/resources/db/migration/`:
- `V1__initial_schema.sql` - Initial database schema
- `V2__add_verification_fields.sql` - Add verification fields
- `V3__populate_sample_data.sql` - Sample data for testing
- `V4__populate_sample_songs.sql` - Sample songs

## 🔐 Authentication

### JWT Token Authentication

The API uses JWT tokens for authentication:

1. **Register/Login** to get a JWT token
2. **Include token** in subsequent requests:
   ```
   Authorization: Bearer <your_jwt_token>
   ```

### Token Structure

```json
{
  "sub": "user@example.com",
  "roles": ["ROLE_USER"],
  "iat": 1234567890,
  "exp": 1234567890
}
```

### Security Configuration

- Public endpoints: `/api/v1/users/register`, `/api/v1/users/login`, `/uploads/**`
- Protected endpoints: All other endpoints require authentication
- Role-based access: DJ-specific endpoints require `ROLE_DJ`

## 💳 Payment Integration

### M-Pesa STK Push

The application integrates with Safaricom M-Pesa for payments:

1. **Initiate Payment**
   ```bash
   POST /api/v1/payment/mpesa/initiate
   {
     "phoneNumber": "254712345678",
     "amount": 100,
     "requestId": "uuid"
   }
   ```

2. **Callback Handling**
   - M-Pesa sends callback to configured URL
   - Payment status updated automatically
   - WebSocket notification sent to client

3. **Check Status**
   ```bash
   GET /api/v1/payment/status/{requestId}
   ```

### Payment Flow

```
User → Initiate Payment → M-Pesa STK Push → User Confirms on Phone
                                                      ↓
Client ← WebSocket Update ← Backend ← M-Pesa Callback
```

## 📁 Project Structure

```
backend/
├── src/
│   ├── main/
│   │   ├── java/com/spinwish/backend/
│   │   │   ├── config/              # Configuration classes
│   │   │   ├── controllers/         # REST controllers
│   │   │   ├── entities/            # JPA entities
│   │   │   ├── enums/               # Enumerations
│   │   │   ├── exceptions/          # Custom exceptions
│   │   │   ├── interceptors/        # Request interceptors
│   │   │   ├── models/              # DTOs and request/response models
│   │   │   ├── monitoring/          # Metrics and monitoring
│   │   │   ├── repositories/        # JPA repositories
│   │   │   ├── security/            # Security configuration
│   │   │   ├── services/            # Business logic
│   │   │   ├── utils/               # Utility classes
│   │   │   └── validators/          # Custom validators
│   │   └── resources/
│   │       ├── application.properties
│   │       ├── application-dev.properties
│   │       ├── application-prod.properties
│   │       └── db/migration/        # Flyway migrations
│   └── test/                        # Unit and integration tests
├── uploads/                         # Uploaded files
├── data/                            # H2 database files
├── Dockerfile                       # Docker configuration
├── pom.xml                          # Maven dependencies
└── README.md                        # This file
```

## 🧪 Testing

### Run Tests

```bash
# Run all tests
./mvnw test

# Run specific test class
./mvnw test -Dtest=UserServiceTest

# Run with coverage
./mvnw test jacoco:report
```

### Test Categories

- **Unit Tests** - Service and utility class tests
- **Integration Tests** - Database and API integration tests
- **Controller Tests** - REST endpoint tests

## 🚢 Deployment

### Production Build

```bash
./mvnw clean package -DskipTests
java -jar target/backend-0.0.1-SNAPSHOT.jar
```

### Environment Configuration

Set production environment variables:

```bash
export SPRING_PROFILES_ACTIVE=prod
export DATABASE_URL=jdbc:postgresql://prod-host:5432/spinwish
export MPESA_CALLBACK_URL=https://api.spinwish.com/api/v1/payment/mpesa/callback
```

### Health Checks

Monitor application health:
- Health endpoint: `GET /actuator/health`
- Metrics: `GET /actuator/metrics`
- Prometheus: `GET /actuator/prometheus`

## 📖 Additional Documentation

- [Error Handling Guide](ERROR_HANDLING_COMPREHENSIVE_GUIDE.md)
- [Database Analysis](DATABASE_ANALYSIS_REPORT.md)
- [Swagger Setup](SWAGGER_SETUP.md)
- [Quick Reference](../QUICK_REFERENCE.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- **SpinWish Team** - Initial work

## 🙏 Acknowledgments

- Spring Boot team for the excellent framework
- Safaricom for M-Pesa API
- All contributors and testers

## 📞 Support

For support, email support@spinwish.com or open an issue on GitHub.

---

**Built with ❤️ by the SpinWish Team**

