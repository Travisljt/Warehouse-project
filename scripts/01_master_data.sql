-- =============================================
-- WMS Database Schema - Master Data Tables
-- =============================================
-- Description: Creates master data tables for WMS system
-- Author: System Generated
-- Date: 2025-11-25
-- =============================================

-- =============================================
-- 1. Owner Table (货主表)
-- =============================================
CREATE TABLE wms_owner (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    code VARCHAR(50) NOT NULL UNIQUE COMMENT '货主编码',
    name VARCHAR(100) NOT NULL COMMENT '货主名称',
    
    -- Base Entity Fields
    create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    create_by VARCHAR(50) COMMENT '创建人',
    update_date TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    update_by VARCHAR(50) COMMENT '更新人',
    delete_flag INT NOT NULL DEFAULT 0 COMMENT '逻辑删除标志 (0:存在, 1:删除)',
    version INT NOT NULL DEFAULT 1 COMMENT '乐观锁版本号',
    
    INDEX idx_code (code),
    INDEX idx_delete_flag (delete_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='货主表';

-- =============================================
-- 2. Contact Table (联系方式表)
-- =============================================
CREATE TABLE wms_contact (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    owner_id BIGINT NOT NULL COMMENT '所属货主ID',
    contact_name VARCHAR(100) NOT NULL COMMENT '联系人姓名',
    phone VARCHAR(50) COMMENT '联系电话',
    mobile VARCHAR(50) COMMENT '手机号码',
    email VARCHAR(100) COMMENT '电子邮箱',
    address VARCHAR(500) COMMENT '联系地址',
    is_primary INT DEFAULT 0 COMMENT '是否主要联系人 (1:是, 0:否)',
    remark VARCHAR(500) COMMENT '备注',
    
    -- Base Entity Fields
    create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    create_by VARCHAR(50) COMMENT '创建人',
    update_date TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    update_by VARCHAR(50) COMMENT '更新人',
    delete_flag INT NOT NULL DEFAULT 0 COMMENT '逻辑删除标志 (0:存在, 1:删除)',
    version INT NOT NULL DEFAULT 1 COMMENT '乐观锁版本号',
    
    INDEX idx_owner_id (owner_id),
    INDEX idx_delete_flag (delete_flag),
    FOREIGN KEY (owner_id) REFERENCES wms_owner(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='联系方式表';

-- =============================================
-- 3. Product Category Table (产品类别表)
-- =============================================
CREATE TABLE wms_product_category (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    code VARCHAR(50) NOT NULL UNIQUE COMMENT '类别编码',
    name VARCHAR(100) NOT NULL COMMENT '类别名称',
    parent_id BIGINT COMMENT '父类别ID (支持多级分类)',
    level INT DEFAULT 1 COMMENT '层级深度',
    path VARCHAR(500) COMMENT '层级路径 (如: /1/2/3/)',
    sort_order INT DEFAULT 0 COMMENT '排序序号',
    
    -- Base Entity Fields
    create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    create_by VARCHAR(50) COMMENT '创建人',
    update_date TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    update_by VARCHAR(50) COMMENT '更新人',
    delete_flag INT NOT NULL DEFAULT 0 COMMENT '逻辑删除标志 (0:存在, 1:删除)',
    version INT NOT NULL DEFAULT 1 COMMENT '乐观锁版本号',
    
    INDEX idx_code (code),
    INDEX idx_parent_id (parent_id),
    INDEX idx_delete_flag (delete_flag),
    FOREIGN KEY (parent_id) REFERENCES wms_product_category(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='产品类别表';

-- =============================================
-- 4. Product Table (产品/物料表)
-- =============================================
CREATE TABLE wms_product (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    owner_id BIGINT NOT NULL COMMENT '所属货主ID',
    category_id BIGINT COMMENT '产品类别ID',
    code VARCHAR(50) NOT NULL COMMENT '产品编码',
    name VARCHAR(200) NOT NULL COMMENT '产品名称',
    short_name VARCHAR(100) COMMENT '产品简称',
    unit VARCHAR(20) NOT NULL COMMENT '基本单位 (如: 个, 箱, kg)',
    spec TEXT COMMENT '规格信息 (JSON格式: 长、宽、高、重)',
    batch_rules TEXT COMMENT '批次管理规则 (JSON格式)',
    shelf_life_days INT COMMENT '保质期天数',
    storage_condition VARCHAR(50) COMMENT '存储条件 (常温/冷藏/冷冻)',
    
    -- Base Entity Fields
    create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    create_by VARCHAR(50) COMMENT '创建人',
    update_date TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    update_by VARCHAR(50) COMMENT '更新人',
    delete_flag INT NOT NULL DEFAULT 0 COMMENT '逻辑删除标志 (0:存在, 1:删除)',
    version INT NOT NULL DEFAULT 1 COMMENT '乐观锁版本号',
    
    UNIQUE KEY uk_owner_code (owner_id, code),
    INDEX idx_owner_id (owner_id),
    INDEX idx_category_id (category_id),
    INDEX idx_code (code),
    INDEX idx_delete_flag (delete_flag),
    FOREIGN KEY (owner_id) REFERENCES wms_owner(id),
    FOREIGN KEY (category_id) REFERENCES wms_product_category(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='产品/物料表';

-- =============================================
-- 5. Barcode Table (条码映射表)
-- =============================================
CREATE TABLE wms_barcode (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    product_id BIGINT NOT NULL COMMENT '对应产品ID',
    barcode VARCHAR(100) NOT NULL UNIQUE COMMENT '条码值',
    type VARCHAR(50) COMMENT '条码类型 (EAN/UPC/QR 等)',
    is_primary INT DEFAULT 0 COMMENT '是否主条码 (1:是, 0:否)',
    remark VARCHAR(500) COMMENT '备注',
    
    -- Base Entity Fields
    create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    create_by VARCHAR(50) COMMENT '创建人',
    update_date TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    update_by VARCHAR(50) COMMENT '更新人',
    delete_flag INT NOT NULL DEFAULT 0 COMMENT '逻辑删除标志 (0:存在, 1:删除)',
    version INT NOT NULL DEFAULT 1 COMMENT '乐观锁版本号',
    
    INDEX idx_product_id (product_id),
    INDEX idx_barcode (barcode),
    INDEX idx_delete_flag (delete_flag),
    FOREIGN KEY (product_id) REFERENCES wms_product(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='条码映射表';

-- =============================================
-- End of Master Data Tables
-- =============================================
