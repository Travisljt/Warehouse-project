# Requirements Document

## Introduction

This document defines the requirements for the WMS Master Data Service, a microservice responsible for managing core master data entities including owners (货主), contacts, product categories, products, and barcodes. The service follows a Domain-Driven Design (DDD) architecture with clear separation between application, domain, and infrastructure layers, consistent with the existing WMS backend architecture.

## Glossary

- **Master Data Service**: The microservice that manages all master data entities for the WMS system
- **Owner (货主)**: A customer or tenant who owns inventory in the warehouse
- **Contact**: Contact information associated with an owner
- **Product Category**: A hierarchical classification system for products supporting multi-level categorization
- **Product**: A physical item or material that can be stored in the warehouse
- **Barcode**: A unique identifier that maps to a product for scanning purposes
- **Base Entity**: Common fields inherited by all entities (create_date, create_by, update_date, update_by, delete_flag, version)
- **Logical Delete**: Soft delete mechanism using delete_flag (0=active, 1=deleted)
- **Optimistic Lock**: Concurrency control mechanism using version field
- **DDD (Domain-Driven Design)**: Software design approach organizing code by business domain
- **MyBatis-Plus**: ORM framework for database operations
- **RESTful API**: HTTP-based API following REST architectural principles

## Requirements

### Requirement 1: Owner Management

**User Story:** As a WMS administrator, I want to manage owner (货主) records, so that I can track which customers have inventory in the warehouse.

#### Acceptance Criteria

1. WHEN an administrator creates a new owner with valid code and name, THEN the Master Data Service SHALL persist the owner record with auto-generated ID and base entity fields
2. WHEN an administrator attempts to create an owner with a duplicate code, THEN the Master Data Service SHALL reject the request and return a validation error
3. WHEN an administrator updates an owner record, THEN the Master Data Service SHALL increment the version field and update the update_date and update_by fields
4. WHEN an administrator deletes an owner, THEN the Master Data Service SHALL set delete_flag to 1 without removing the physical record
5. WHEN an administrator queries owners, THEN the Master Data Service SHALL return only records where delete_flag equals 0
6. WHEN concurrent updates occur on the same owner record, THEN the Master Data Service SHALL use the version field to detect conflicts and reject stale updates

### Requirement 2: Contact Management

**User Story:** As a WMS administrator, I want to manage contact information for owners, so that I can communicate with the appropriate people for each customer.

#### Acceptance Criteria

1. WHEN an administrator creates a contact for an owner, THEN the Master Data Service SHALL validate that the owner_id references an existing active owner
2. WHEN an administrator sets a contact as primary (is_primary=1), THEN the Master Data Service SHALL ensure only one primary contact exists per owner
3. WHEN an administrator queries contacts by owner_id, THEN the Master Data Service SHALL return all active contacts ordered by is_primary descending
4. WHEN an owner is logically deleted, THEN the Master Data Service SHALL maintain referential integrity for associated contacts
5. WHEN an administrator updates contact information, THEN the Master Data Service SHALL apply optimistic locking using the version field

### Requirement 3: Product Category Management

**User Story:** As a WMS administrator, I want to manage hierarchical product categories, so that I can organize products into a logical classification structure.

#### Acceptance Criteria

1. WHEN an administrator creates a root category (parent_id is null), THEN the Master Data Service SHALL set level to 1 and path to "/id/"
2. WHEN an administrator creates a child category with a parent_id, THEN the Master Data Service SHALL calculate level as parent_level + 1 and path as parent_path + "id/"
3. WHEN an administrator queries categories, THEN the Master Data Service SHALL support retrieving the full category tree structure
4. WHEN an administrator deletes a category with children, THEN the Master Data Service SHALL prevent deletion and return an error
5. WHEN an administrator updates a category's parent_id, THEN the Master Data Service SHALL recalculate level and path for the category and all descendants
6. WHEN categories are displayed, THEN the Master Data Service SHALL order them by sort_order field

### Requirement 4: Product Management

**User Story:** As a WMS administrator, I want to manage product master data, so that I can define what items can be stored and tracked in the warehouse.

#### Acceptance Criteria

1. WHEN an administrator creates a product, THEN the Master Data Service SHALL enforce uniqueness of code within the same owner_id
2. WHEN an administrator creates a product with spec field, THEN the Master Data Service SHALL validate that spec is valid JSON format
3. WHEN an administrator creates a product with batch_rules field, THEN the Master Data Service SHALL validate that batch_rules is valid JSON format
4. WHEN an administrator queries products by owner_id, THEN the Master Data Service SHALL return all active products with their category information
5. WHEN an administrator queries products by category_id, THEN the Master Data Service SHALL return all active products in that category
6. WHEN an administrator updates a product, THEN the Master Data Service SHALL apply optimistic locking and maintain audit trail

### Requirement 5: Barcode Management

**User Story:** As a WMS administrator, I want to manage barcode mappings for products, so that warehouse operators can scan items for identification.

#### Acceptance Criteria

1. WHEN an administrator creates a barcode, THEN the Master Data Service SHALL enforce global uniqueness of the barcode value
2. WHEN an administrator sets a barcode as primary (is_primary=1), THEN the Master Data Service SHALL ensure only one primary barcode exists per product
3. WHEN an administrator queries by barcode value, THEN the Master Data Service SHALL return the associated product information
4. WHEN a product is logically deleted, THEN the Master Data Service SHALL maintain referential integrity for associated barcodes
5. WHEN an administrator creates multiple barcodes for a product, THEN the Master Data Service SHALL allow different barcode types (EAN/UPC/QR)

### Requirement 6: RESTful API Design

**User Story:** As a frontend developer or API consumer, I want a consistent RESTful API, so that I can easily integrate with the master data service.

#### Acceptance Criteria

1. WHEN the Master Data Service exposes endpoints, THEN the service SHALL follow RESTful conventions (GET for queries, POST for creation, PUT for updates, DELETE for logical deletion)
2. WHEN the Master Data Service returns responses, THEN the service SHALL use the ApiResponse wrapper with consistent structure (code, message, data)
3. WHEN validation errors occur, THEN the Master Data Service SHALL return HTTP 400 with detailed error messages
4. WHEN resource not found errors occur, THEN the Master Data Service SHALL return HTTP 404 with appropriate message
5. WHEN optimistic lock conflicts occur, THEN the Master Data Service SHALL return HTTP 409 with version conflict message
6. WHEN the Master Data Service processes requests, THEN the service SHALL support pagination for list queries using page and size parameters

### Requirement 7: Service Architecture

**User Story:** As a backend developer, I want the master data service to follow DDD architecture, so that the codebase is maintainable and consistent with other services.

#### Acceptance Criteria

1. WHEN the Master Data Service is structured, THEN the service SHALL organize code into application, domain, and config layers
2. WHEN the application layer handles requests, THEN the layer SHALL contain controllers, DTOs, and assemblers
3. WHEN the domain layer implements business logic, THEN the layer SHALL contain entities, mappers, and service implementations
4. WHEN the Master Data Service uses MyBatis-Plus, THEN the service SHALL configure logical delete and optimistic lock globally
5. WHEN the Master Data Service starts, THEN the service SHALL run on port 8082 and register with service discovery if available

### Requirement 8: Data Validation and Integrity

**User Story:** As a system architect, I want comprehensive data validation, so that data integrity is maintained across the system.

#### Acceptance Criteria

1. WHEN the Master Data Service receives create or update requests, THEN the service SHALL validate all required fields are present and non-empty
2. WHEN the Master Data Service validates string fields, THEN the service SHALL enforce maximum length constraints matching database schema
3. WHEN the Master Data Service validates foreign key references, THEN the service SHALL verify referenced entities exist and are active (delete_flag=0)
4. WHEN the Master Data Service validates JSON fields (spec, batch_rules), THEN the service SHALL parse and validate JSON structure
5. WHEN the Master Data Service validates unique constraints, THEN the service SHALL check uniqueness before database operations

### Requirement 9: Query and Search Capabilities

**User Story:** As a WMS user, I want to search and filter master data efficiently, so that I can quickly find the information I need.

#### Acceptance Criteria

1. WHEN a user queries owners, THEN the Master Data Service SHALL support filtering by code or name using partial matching
2. WHEN a user queries products, THEN the Master Data Service SHALL support filtering by owner_id, category_id, code, or name
3. WHEN a user queries contacts, THEN the Master Data Service SHALL support filtering by owner_id
4. WHEN a user queries categories, THEN the Master Data Service SHALL support retrieving by parent_id to build tree structures
5. WHEN a user performs barcode lookup, THEN the Master Data Service SHALL return results in under 100 milliseconds for indexed barcode queries

### Requirement 10: Audit Trail and Tracking

**User Story:** As a compliance officer, I want complete audit trails for master data changes, so that I can track who made what changes and when.

#### Acceptance Criteria

1. WHEN the Master Data Service creates a record, THEN the service SHALL populate create_date with current timestamp and create_by with authenticated user
2. WHEN the Master Data Service updates a record, THEN the service SHALL populate update_date with current timestamp and update_by with authenticated user
3. WHEN the Master Data Service logically deletes a record, THEN the service SHALL preserve all audit fields and set delete_flag to 1
4. WHEN the Master Data Service queries records, THEN the service SHALL include audit fields in response DTOs
5. WHEN the Master Data Service performs operations, THEN the service SHALL extract user identity from authentication context (Sa-Token)
