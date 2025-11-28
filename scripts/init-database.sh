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

# Resolve script and project root so script works when invoked from any CWD
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

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
    done < <(find "$PROJECT_ROOT/backend" -type f -name "*_init.sql" -path "*/src/main/resources/*" -print0 2>/dev/null | sort -z)
    
    if [ ${#DATABASES[@]} -eq 0 ]; then
        print_warning "No *_init.sql files found"
        return 1
    fi
    
    print_success "Discovered ${#DATABASES[@]} database(s)"
    echo ""
}

# Function to drop and recreate a database
recreate_database() {
    local db_name=$1
    
    print_step "Processing database: $db_name"
    
    # Terminate all connections
    PGPASSWORD=$TRAVIS_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $TRAVIS_USER -d postgres -c "
        SELECT pg_terminate_backend(pid) 
        FROM pg_stat_activity 
        WHERE datname = '$db_name' AND pid <> pg_backend_pid();
    " > /dev/null 2>&1
    
    # Drop database if exists
    PGPASSWORD=$TRAVIS_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $TRAVIS_USER -d postgres -c "
        DROP DATABASE IF EXISTS $db_name;
    " > /dev/null 2>&1
    
    # Create database
    PGPASSWORD=$TRAVIS_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $TRAVIS_USER -d postgres -c "
        CREATE DATABASE $db_name;
    " > /dev/null 2>&1
    
    print_success "✓ Database '$db_name' recreated"
}

# Function to create database user
create_database_user() {
    local db_name=$1
    local username=$db_name
    local password=$db_name
    
    # Check if user exists
    USER_EXISTS=$(PGPASSWORD=$TRAVIS_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $TRAVIS_USER -d postgres -tAc "SELECT 1 FROM pg_user WHERE usename='$username'")
    
    if [ "$USER_EXISTS" = "1" ]; then
        print_info "  User '$username' already exists"
    else
        PGPASSWORD=$TRAVIS_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $TRAVIS_USER -d postgres -c "
            CREATE USER $username WITH PASSWORD '$password';
        " > /dev/null 2>&1
        print_success "  ✓ User '$username' created (password: $password)"
    fi
    
    # Grant privileges
    PGPASSWORD=$TRAVIS_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $TRAVIS_USER -d postgres -c "
        GRANT ALL PRIVILEGES ON DATABASE $db_name TO $username;
    " > /dev/null 2>&1
}

# Function to execute SQL file
execute_sql_file() {
    local sql_file=$1
    local db_name=$2
    local file_type=$3
    
    print_step "  Executing: $(basename $sql_file)"
    
    if PGPASSWORD=$TRAVIS_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $TRAVIS_USER -d $db_name -f "$sql_file" > /dev/null 2>&1; then
        print_success "  ✓ Successfully executed"
        return 0
    else
        print_error "  ✗ Failed to execute"
        return 1
    fi
}

# Function to grant all privileges on all tables, sequences, and functions to the database user
# This ensures new tables/functions are always授权, following open-closed principle
grant_all_privileges() {
    local db_name=$1
    local username=$db_name
    print_info "Granting all privileges on tables, sequences, and functions in '$db_name' to user '$username'..."
    
    # Step 1: Grant on all existing tables
    PGPASSWORD=$TRAVIS_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $TRAVIS_USER -d $db_name <<EOF > /dev/null 2>&1
        -- Grant on all tables
        GRANT USAGE ON SCHEMA public TO $username;
        GRANT CREATE ON SCHEMA public TO $username;
        DO \$\$
        DECLARE
            r RECORD;
        BEGIN
            FOR r IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
                EXECUTE 'GRANT ALL PRIVILEGES ON TABLE public.' || quote_ident(r.tablename) || ' TO $username';
            END LOOP;
        END
        \$\$;
        
        -- Grant on all sequences
        DO \$\$
        DECLARE
            r RECORD;
        BEGIN
            FOR r IN SELECT sequencename FROM pg_sequences WHERE schemaname = 'public' LOOP
                EXECUTE 'GRANT ALL PRIVILEGES ON SEQUENCE public.' || quote_ident(r.sequencename) || ' TO $username';
            END LOOP;
        END
        \$\$;
        
        -- Grant default privileges for future tables/sequences
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO $username;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO $username;
EOF
    
    if [ $? -eq 0 ]; then
        print_success "  ✓ All privileges granted to '$username' in '$db_name'"
    else
        print_error "  ✗ Failed to grant privileges to '$username' in '$db_name'"
        return 1
    fi
}

# Function to initialize all databases
initialize_databases() {
    local init_success=0
    local init_fail=0
    local insert_success=0
    local insert_fail=0
    
    for db_name in "${!DATABASES[@]}"; do
        echo "========================================"
        echo "  Database: $db_name"
        echo "========================================"
        echo ""
        
        # Step 1: Recreate database
        recreate_database "$db_name"
        
        # Step 2: Create database user
        create_database_user "$db_name"
        echo ""
        
        # Step 3: Execute init SQL
        print_info "Executing schema initialization..."
        init_file="${DATABASES[$db_name]}"
        if execute_sql_file "$init_file" "$db_name" "INIT"; then
            init_success=$((init_success + 1))
            # 授权所有表/序列/函数给同名用户，保证开闭原则
            grant_all_privileges "$db_name"
        else
            init_fail=$((init_fail + 1))
        fi
        echo ""
        
        # Step 4: Execute insert SQL (if exists)
        insert_file="${init_file%_init.sql}_insert.sql"
        if [ -f "$insert_file" ]; then
            print_info "Executing data insertion..."
            if execute_sql_file "$insert_file" "$db_name" "INSERT"; then
                insert_success=$((insert_success + 1))
            else
                insert_fail=$((insert_fail + 1))
            fi
        else
            print_info "No insert file found (optional)"
        fi
        echo ""
    done
    
    # Summary
    echo "========================================"
    echo "  Execution Summary"
    echo "========================================"
    echo ""
    echo "Schema Initialization (*_init.sql):"
    echo "  ${GREEN}✓ Success: $init_success${NC}"
    if [ $init_fail -gt 0 ]; then
        echo "  ${RED}✗ Failed: $init_fail${NC}"
    fi
    echo ""
    echo "Data Insertion (*_insert.sql):"
    echo "  ${GREEN}✓ Success: $insert_success${NC}"
    if [ $insert_fail -gt 0 ]; then
        echo "  ${RED}✗ Failed: $insert_fail${NC}"
    fi
    echo ""
    echo "Total:"
    echo "  ${GREEN}✓ Success: $((init_success + insert_success))${NC}"
    if [ $((init_fail + insert_fail)) -gt 0 ]; then
        echo "  ${RED}✗ Failed: $((init_fail + insert_fail))${NC}"
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
    echo "  Host: $DB_HOST"
    echo "  Port: $DB_PORT"
    echo "  Travis User: $TRAVIS_USER"
    echo ""
    
    # Step 1: Check PostgreSQL connection
    if ! check_postgres; then
        exit 1
    fi
    echo ""
    
    # Step 2: Create travis superuser
    echo "========================================"
    echo "  Step 1: Setup Travis User"
    echo "========================================"
    echo ""
    create_travis_user
    echo ""
    
    # Step 3: Discover databases
    echo "========================================"
    echo "  Step 2: Discover Databases"
    echo "========================================"
    echo ""
    if ! discover_databases; then
        print_error "No databases to initialize"
        exit 1
    fi
    
    # Step 4: Initialize all databases
    echo "========================================"
    echo "  Step 3: Initialize Databases"
    echo "========================================"
    echo ""
    initialize_databases
    
    echo ""
    print_success "Database initialization completed!"
    echo ""
}

# Run main function
main
