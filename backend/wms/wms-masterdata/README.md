# WMS Master Data Service

## Overview

The Master Data Service is a core microservice in the WMS (Warehouse Management System) that manages all master data entities including:

- **Owners (货主)**: Customer or tenant information
- **Contacts**: Contact information for owners
- **Product Categories**: Hierarchical product classification
- **Products**: Product master data
- **Barcodes**: Product barcode mappings

## Architecture

This service follows Domain-Driven Design (DDD) principles with the following layers:

- **Application Layer**: Controllers, DTOs, and Assemblers
- **Domain Layer**: Entities, Mappers, and Services
- **Config Layer**: Configuration classes

## Technology Stack

- Spring Boot 3.0.13
- MyBatis-Plus 3.5.9
- PostgreSQL 42.7.4
- Sa-Token 1.38.0
- jqwik 1.7.4 (for property-based testing)

## Configuration

The service runs on port **8082** by default.

### Database Configuration

Configure the following environment variables:

- `WMS_DB_URL`: Database URL (default: `jdbc:postgresql://localhost:5432/wms`)
- `WMS_DB_USERNAME`: Database username (default: `wms`)
- `WMS_DB_PASSWORD`: Database password (default: `wms@123`)

## Building

```bash
mvn clean install
```

## Running

```bash
mvn spring-boot:run
```

Or run the packaged JAR:

```bash
java -jar target/wms-masterdata-0.1.0-SNAPSHOT.jar
```

## Testing

Run all tests:

```bash
mvn test
```

## API Documentation

The service exposes RESTful APIs under the `/api/masterdata` path:

- `/api/masterdata/owners` - Owner management
- `/api/masterdata/contacts` - Contact management
- `/api/masterdata/categories` - Product category management
- `/api/masterdata/products` - Product management
- `/api/masterdata/barcodes` - Barcode management

## Project Structure

```
src/main/java/com/example/wms/masterdata/
├── MasterDataServiceApplication.java
├── application/
│   ├── controller/     # REST controllers
│   ├── dto/           # Data Transfer Objects
│   └── assembler/     # DTO-Entity converters
├── domain/
│   ├── entity/        # Domain entities
│   ├── mapper/        # MyBatis mappers
│   └── service/       # Business logic
│       └── impl/      # Service implementations
└── config/            # Configuration classes
```

## Features

- **Logical Delete**: All entities support soft delete using `delete_flag`
- **Optimistic Locking**: Version-based concurrency control
- **Audit Trail**: Automatic tracking of create/update timestamps and users
- **Pagination**: All list queries support pagination
- **Validation**: Comprehensive input validation
- **Property-Based Testing**: Correctness properties verified with jqwik

## Development

This service is part of the WMS backend project. See the parent project documentation for more details.
