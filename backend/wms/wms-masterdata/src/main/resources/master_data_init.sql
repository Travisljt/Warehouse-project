-- =============================================
-- WMS Master Data Service Database Schema
-- =============================================
-- Description: Creates master data tables for WMS system
-- Service: wms-masterdata
-- Date: 2025-11-27
-- =============================================

-- =============================================
-- Owner Table (货主表)
-- =============================================
CREATE TABLE IF NOT EXISTS wms_owner (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    
    -- Base Entity Fields
    create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_date TIMESTAMP,
    update_by VARCHAR(50),
    delete_flag INT NOT NULL DEFAULT 0,
    version INT NOT NULL DEFAULT 1
);

CREATE INDEX IF NOT EXISTS idx_owner_code ON wms_owner(code);
CREATE INDEX IF NOT EXISTS idx_owner_delete_flag ON wms_owner(delete_flag);

-- =============================================
-- Contact Table (联系方式表)
-- =============================================
CREATE TABLE IF NOT EXISTS wms_contact (
    id BIGSERIAL PRIMARY KEY,
    owner_id BIGINT NOT NULL,
    contact_name VARCHAR(100) NOT NULL,
    phone VARCHAR(50),
    mobile VARCHAR(50),
    email VARCHAR(100),
    address VARCHAR(500),
    is_primary INT DEFAULT 0,
    remark VARCHAR(500),
    
    -- Base Entity Fields
    create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_date TIMESTAMP,
    update_by VARCHAR(50),
    delete_flag INT NOT NULL DEFAULT 0,
    version INT NOT NULL DEFAULT 1,
    
    FOREIGN KEY (owner_id) REFERENCES wms_owner(id)
);

CREATE INDEX IF NOT EXISTS idx_contact_owner_id ON wms_contact(owner_id);
CREATE INDEX IF NOT EXISTS idx_contact_delete_flag ON wms_contact(delete_flag);

-- =============================================
-- Product Category Table (产品类别表)
-- =============================================
CREATE TABLE IF NOT EXISTS wms_product_category (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    parent_id BIGINT,
    level INT DEFAULT 1,
    path VARCHAR(500),
    sort_order INT DEFAULT 0,
    
    -- Base Entity Fields
    create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_date TIMESTAMP,
    update_by VARCHAR(50),
    delete_flag INT NOT NULL DEFAULT 0,
    version INT NOT NULL DEFAULT 1,
    
    FOREIGN KEY (parent_id) REFERENCES wms_product_category(id)
);

CREATE INDEX IF NOT EXISTS idx_category_code ON wms_product_category(code);
CREATE INDEX IF NOT EXISTS idx_category_parent_id ON wms_product_category(parent_id);
CREATE INDEX IF NOT EXISTS idx_category_delete_flag ON wms_product_category(delete_flag);

-- =============================================
-- Product Table (产品/物料表)
-- =============================================
CREATE TABLE IF NOT EXISTS wms_product (
    id BIGSERIAL PRIMARY KEY,
    owner_id BIGINT NOT NULL,
    category_id BIGINT,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(200) NOT NULL,
    short_name VARCHAR(100),
    unit VARCHAR(20) NOT NULL,
    spec TEXT,
    batch_rules TEXT,
    shelf_life_days INT,
    storage_condition VARCHAR(50),
    
    -- Base Entity Fields
    create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_date TIMESTAMP,
    update_by VARCHAR(50),
    delete_flag INT NOT NULL DEFAULT 0,
    version INT NOT NULL DEFAULT 1,
    
    UNIQUE (owner_id, code),
    FOREIGN KEY (owner_id) REFERENCES wms_owner(id),
    FOREIGN KEY (category_id) REFERENCES wms_product_category(id)
);

CREATE INDEX IF NOT EXISTS idx_product_owner_id ON wms_product(owner_id);
CREATE INDEX IF NOT EXISTS idx_product_category_id ON wms_product(category_id);
CREATE INDEX IF NOT EXISTS idx_product_code ON wms_product(code);
CREATE INDEX IF NOT EXISTS idx_product_delete_flag ON wms_product(delete_flag);

-- =============================================
-- Barcode Table (条码映射表)
-- =============================================
CREATE TABLE IF NOT EXISTS wms_barcode (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    barcode VARCHAR(100) NOT NULL UNIQUE,
    type VARCHAR(50),
    is_primary INT DEFAULT 0,
    remark VARCHAR(500),
    
    -- Base Entity Fields
    create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_date TIMESTAMP,
    update_by VARCHAR(50),
    delete_flag INT NOT NULL DEFAULT 0,
    version INT NOT NULL DEFAULT 1,
    
    FOREIGN KEY (product_id) REFERENCES wms_product(id)
);

CREATE INDEX IF NOT EXISTS idx_barcode_product_id ON wms_barcode(product_id);
CREATE INDEX IF NOT EXISTS idx_barcode_barcode ON wms_barcode(barcode);
CREATE INDEX IF NOT EXISTS idx_barcode_delete_flag ON wms_barcode(delete_flag);
