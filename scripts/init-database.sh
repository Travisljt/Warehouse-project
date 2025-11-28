#!/bin/bash

# =============================================
# WMS Database Initialization Script
# =============================================
# Description: 
#   1. Creates travis superuser (if not exists)
#   2. Dynamically discovers databases from *_init.sql files
#   3. Drops and recreates discovered databases
#   4. Creates database users (username = database name, password = database name)
#   5. Executes all *_init.sql and *_insert.sql files
# 
# Design Principle: Open-Closed Principle
#   - Open for extension: Add new service with *_init.sql, script auto-discovers it
#   - Closed for modification: No need to modify this script when adding new services
#
# Environment Variables:
#   POSTGRES_PASSWORD - Password for postgres superuser (default: postgres)
#   DB_HOST          - Database host (default: localhost)
#   DB_PORT          - Database port (default: 5432)
#
# Author: System Generated
# Date: 2025-11-28
# =============================================

set -e  # Exit on error

# Database configuration
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-postgres}"
TRAVIS_USER="travis"
TRAVIS_PASSWORD="39287526"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# Function to check if PostgreSQL is available
check_postgres() {
    print_info "Checking PostgreSQL connection..."
    if PGPASSWORD=$POSTGRES_PASSWORD psql -h $DB_HOST -p $DB_PORT -U postgres -d postgres -c '\q' 2>/dev/null; then
        print_success "PostgreSQL is accessible"
        return 0
    else
        print_error "Cannot connect to PostgreSQL at $DB_HOST:$DB_PORT"
        print_error "Please ensure PostgreSQL is running and POSTGRES_PASSWORD is correct"
        return 1
    fi
}

# Function to create travis superuser if not exists
create_travis_user() {
    print_info "Checking if user 'travis' exists..."
    
    USER_EXISTS=$(PGPASSWORD=$POSTGRES_PASSWORD psql -h $DB_HOST -p $DB_PORT -U postgres -d postgres -tAc "SELECT 1 FROM pg_user WHERE usename='$TRAVIS_USER'")
    
    if [ "$USER_EXISTS" = "1" ]; then
        print_success "User 'travis' already exists, using existing user"
    else
        print_info "Creating superuser 'travis'..."
        PGPASSWORD=$POSTGRES_PASSWORD psql -h $DB_HOST -p $DB_PORT -U postgres -d postgres -c "
            CREATE USER $TRAVIS_USER WITH SUPERUSER PASSWORD '$TRAVIS_PASSWORD';
        " > /dev/null 2>&1
        print_success "✓ Superuser 'travis' created successfully"
    fi
}

# Function to discover databases from *_init.sql files
discover_databases() {
    print_info "Discovering databases from *_init.sql files..."
    
    declare -g -A DATABASES
    
    while IFS= read -r -d '' sql_file; do
        # Extract filename without path
        filename=$(basename "$sql_file")
        # Extract database name (everything before _init.sql)
        db_name="${filename%_init.sql}"
        
        if [ -n "$db_name" ]; then
            DATABASES["$db_name"]="$sql_file"
            print_step "Found database: $db_name (from $filename)"
        fi
    done < <(find backend -type f -name "*_init.sql" -path "*/src/main/resources/*" -print0 2>/dev/null | sort -z)
    
    if [ ${#DATABASES[@]} -eq 0 ]; then
        print_warning "No *_init.sql files found"
        return 1
    fi
    
    print_success "Discovered ${#DATABASES[@]} database(s)"
    echo ""
}

# Function to drop atname = '$db_name' AND pid <> pg_backend_pid();
        " > /dev/null 2>&1
        
        # Drop the database
        PGPASSWORD=${POSTGRES_PASSWORD} psql -h $DB_HOST -p $DB_PORT -U postgres -d postgres -c "DROP DATABASE IF EXISTS \"$db_name\";" > /dev/null 2>&1
        print_success "  ✓ Dropped database: $db_name"
    done
    echo ""
}

# Function to create travis superuser if not exists
create_travis_user() {
    print_info "Checking if user '$TRAVIS_USER' exists..."
    
    USER_EXISTS=$(PGPASSWORD=${POSTGRES_PASSWORD} psql -h $DB_HOST -p $DB_PORT -U postgres -d postgres -tAc "SELECT 1 FROM pg_user WHERE usename='$TRAVIS_USER'")
    
    if [ "$USER_EXISTS" = "1" ]; then
        print_success "  ✓ User '$TRAVIS_USER' already exists, using existing user"
    else
        print_info "Creating superuser '$TRAVIS_USER'..."
        PGPASSWORD=${POSTGRES_PASSWORD} psql -h $DB_HOST -p $DB_PORT -U postgres -d postgres -c "
            CREATE USER $TRAVIS_USER WITH SUPERUSER PASSWORD '$TRAVIS_PASSWORD';
        " > /dev/null 2>&1
        print_success "  ✓ Superuser '$TRAVIS_USER' created successfully"
    fi
    echo ""
}

# Function to create database and its user
create_database_and_user() {
    local db_name=$1
    local db_user=$db_name
    local db_password=$db_name
    
    print_step "Setting up database: $db_name"
    
    # Create user if not exists
    USER_EXISTS=$(PGPASSWORD=${TRAVIS_PASSWORD} psql -h $DB_HOST -p $DB_PORT -U $TRAVIS_USER -d postgres -tAc "SELECT 1 FROM pg_user WHERE usename='$db_user'")
    
    if [ "$USER_EXISTS" = "1" ]; then
        print_info "  User '$db_user' already exists"
    else
        PGPASSWORD=${TRAVIS_PASSWORD} psql -h $DB_HOST -p $DB_PORT -U $TRAVIS_USER -d postgres -c "
            CREATE USER \"$db_user\" WITH PASSWORD '$db_password';
        " > /dev/null 2>&1
        print_success "  ✓ Created user: $db_user (password: $db_password)"
    fi
    
    # Create database
    PGPASSWORD=${TRAVIS_PASSWORD} psql -h $DB_HOST -p $DB_PORT -U $TRAVIS_USER -d postgres -c "
        CREATE DATABASE \"$db_name\" OWNER \"$db_user\";
    " > /dev/null 2>&1
    print_success "  ✓ Created database: $db_name (owner: $db_user)"
    
    # Grant all privileges
    PGPASSWORD=${TRAVIS_PASSWORD} psql -h $DB_HOST -p $DB_PORT -U $TRAVIS_USER -d postgres -c "
        GRANT ALL PRIVILEGES ON DATABASE \"$db_name\" TO \"$db_user\";
    " > /dev/null 2>&1
    print_success "  ✓ Granted privileges to user: $db_user"
    echo ""
}

# Function to execute SQL file for a specific database
execute_sql_file() {
    local sql_file=$1
    local db_name=$2
    local db_user=$db_name
    local db_password=$db_name
    local service_name=$3
    local file_type=$4
    
    print_step "  Executing: $(basename $sql_file)"
    echo "           Service: $service_name | Type: $file_type | Database: $db_name"
    
    if PGPASSWORD=$db_password psql -h $DB_HOST -p $DB_PORT -U $db_user -d $db_name -f "$sql_file" > /dev/null 2>&1; then
        print_success "  ✓ Successfully executed"
        return 0
    else
        print_error "  ✗ Failed to execute"
        print_warning "  Continuing with next file..."
        return 1
    fi
}

# Function to initialize all databases with their SQL files
initialize_all_databases() {
    print_info "Initializing all discovered databases..."
    echo ""
    
    local total_success=0
    local total_fail=0
    
    # Process each discovered database
    for db_name in "${DISCOVERED_DATABASES[@]}"; do
        echo "========================================"
        echo "  Database: $db_name"
        echo "========================================"
        echo ""
        
        local db_success=0
        local db_fail=0
        
        # Phase 1: Execute *_init.sql for this database
        print_info "Phase 1: Creating tables for '$db_name'..."
        
        while IFS= read -r sql_file; do
            # Extract service name from path
            service_name=$(echo "$sql_file" | sed -E 's|.*backend/([^/]+/[^/]+)/.*|\1|')
            
            if execute_sql_file "$sql_file" "$db_name" "$service_name" "INIT"; then
                db_success=$((db_success + 1))
            else
                db_fail=$((db_fail + 1))
            fi
        done < <(find backend -type f -path "*/src/main/resources/${db_name}_init.sql" | sort)
        
        echo ""
        
        # Phase 2: Execute *_insert.sql for this database
        print_info "Phase 2: Inserting data for '$db_name'..."
        
        while IFS= read -r sql_file; do
            # Extract service name from path
            service_name=$(echo "$sql_file" | sed -E 's|.*backend/([^/]+/[^/]+)/.*|\1|')
            
            if execute_sql_file "$sql_file" "$db_name" "$service_name" "INSERT"; then
                db_success=$((db_success + 1))
            else
                db_fail=$((db_fail + 1))
            fi
        done < <(find backend -type f -path "*/src/main/resources/${db_name}_insert.sql" | sort)
        
        echo ""
        print_success "Database '$db_name' initialized: ✓ $db_success succeeded, ✗ $db_fail failed"
        echo ""
        
        total_success=$((total_success + db_success))
        total_fail=$((total_fail + db_fail))
    done
    
    # Final Summary
    echo "========================================"
    echo "  Final Summary"
    echo "========================================"
    echo ""
    echo "Total SQL files executed:"
    echo "  ${GREEN}✓ Success: $total_success${NC}"
    if [ $total_fail -gt 0 ]; then
        echo "  ${RED}✗ Failed: $total_fail${NC}"
    fi
    echo "========================================"
}

# Main execution
main() {
    echo ""
    echo "========================================"
    echo "  WMS Database Initialization"
    echo "  (Open-Closed Principle Design)"
    echo "========================================"
    echo ""
    echo "Configuration:"
    echo "  Host:          $DB_HOST"
    echo "  Port:          $DB_PORT"
    echo "  Travis User:   $TRAVIS_USER"
    echo ""
    
    # Check PostgreSQL connection (as postgres superuser)
    if ! check_postgres; then
        exit 1
    fi
    echo ""
    
    # Step 1: Discover databases from *_init.sql files
    echo "========================================"
    echo "  Step 1: Discovering Databases"
    echo "========================================"
    echo ""
    discover_databases
    
    if [ ${#DISCOVERED_DATABASES[@]} -eq 0 ]; then
        print_error "No databases discovered. Exiting."
        exit 1
    fi
    
    # Step 2: Create travis superuser
    echo "========================================"
    echo "  Step 2: Creating Travis Superuser"
    echo "========================================"
    echo ""
    create_travis_user
    
    # Step 3: Drop discovered databases
    echo "========================================"
    echo "  Step 3: Dropping Discovered Databases"
    echo "========================================"
    echo ""
    drop_discovered_databases
    
    # Step 4: Create databases and users
    echo "========================================"
    echo "  Step 4: Creating Databases & Users"
    echo "========================================"
    echo ""
    for db_name in "${DISCOVERED_DATABASES[@]}"; do
        create_database_and_user "$db_name"
    done
    
    # Step 5: Initialize all databases
    echo "========================================"
    echo "  Step 5: Initializing Databases"
    echo "========================================"
    echo ""
    initialize_all_databases
    
    echo ""
    print_success "✓ All databases initialized successfully!"
    echo ""
    echo "Database Summary:"
    for db_name in "${DISCOVERED_DATABASES[@]}"; do
        echo "  • Database: $db_name | User: $db_name | Password: $db_name"
    done
    echo ""
}

# Run main function
main
