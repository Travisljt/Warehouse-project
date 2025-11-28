-- =============================================
-- WMS Master Data Service Default Data
-- =============================================
-- Description: Inserts default master data
-- Service: wms-masterdata
-- Date: 2025-11-27
-- =============================================

-- =============================================
-- Default Owner
-- =============================================
INSERT INTO wms_owner (code, name, create_by)
VALUES ('DEFAULT', '默认货主', 'system')
ON CONFLICT (code) DO NOTHING;

-- =============================================
-- Default Product Categories
-- =============================================
INSERT INTO wms_product_category (code, name, level, create_by)
VALUES 
    ('GENERAL', '通用类别', 1, 'system'),
    ('FOOD', '食品类', 1, 'system'),
    ('ELECTRONICS', '电子产品', 1, 'system')
ON CONFLICT (code) DO NOTHING;
