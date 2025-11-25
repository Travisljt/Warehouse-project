# WMS Database Schema Design

Based on the requirements in `docs/wms-wcs.md`, here is the proposed database schema design for the WMS (Warehouse Management System).

## 1. Entity Relationship Diagram (ERD)

```mermaid
erDiagram
    %% Master Data
    OWNER ||--o{ SKU : owns
    WAREHOUSE ||--o{ ZONE : contains
    ZONE ||--o{ LOCATION : contains
    
    %% Inbound
    OWNER ||--o{ ASN : creates
    ASN ||--o{ ASN_DETAIL : has
    ASN_DETAIL ||--o{ RECEIPT : receives
    
    %% Inventory
    SKU ||--o{ INVENTORY : stocks
    LOCATION ||--o{ INVENTORY : stores
    CONTAINER ||--o{ INVENTORY : holds
    
    %% Outbound
    OWNER ||--o{ ORDER : places
    ORDER ||--o{ ORDER_DETAIL : has
    WAVE ||--o{ ORDER : includes
    ORDER_DETAIL ||--o{ PICK_TASK : generates
    
    %% Tasks
    PICK_TASK }|--|| LOCATION : from
    PICK_TASK }|--|| CONTAINER : from_to

    class OWNER {
        bigint id PK
        string code
        string name
        string contact_info
    }
    
    class SKU {
        bigint id PK
        bigint owner_id FK
        string code
        string name
        string barcode
        jsonb specifications
    }
    
    class WAREHOUSE {
        bigint id PK
        string code
        string name
        string address
    }
    
    class LOCATION {
        bigint id PK
        bigint zone_id FK
        string code
        string type
        boolean is_occupied
    }
    
    class INVENTORY {
        bigint id PK
        bigint location_id FK
        bigint sku_id FK
        decimal quantity
        string batch_no
        string status
    }
```

## 2. Table Definitions

### 2.1 Master Data (主数据)

#### `wms_owner` (货主)
| Column | Type | Constraint | Description |
|---|---|---|---|
| id | BIGINT | PK, Auto Inc | Primary Key |
| code | VARCHAR(50) | UK, Not Null | Owner Code |
| name | VARCHAR(100) | Not Null | Owner Name |
| status | INT | Default 1 | 1: Active, 0: Inactive |
| created_at | TIMESTAMP | Default Now | Creation Time |

#### `wms_sku` (物料/SKU)
| Column | Type | Constraint | Description |
|---|---|---|---|
| id | BIGINT | PK, Auto Inc | Primary Key |
| owner_id | BIGINT | FK, Not Null | Owner ID |
| code | VARCHAR(50) | UK (with owner), Not Null | SKU Code |
| name | VARCHAR(200) | Not Null | SKU Name |
| barcode | VARCHAR(100) | Index | Barcode/UPC |
| unit | VARCHAR(20) | Not Null | Base Unit (e.g., PCS, KG) |
| spec | JSONB | | Specifications (Length, Width, Height, Weight) |
| batch_rules | JSONB | | Batch management rules (e.g., expiry date required) |

#### `wms_warehouse` (仓库)
| Column | Type | Constraint | Description |
|---|---|---|---|
| id | BIGINT | PK, Auto Inc | Primary Key |
| code | VARCHAR(50) | UK, Not Null | Warehouse Code |
| name | VARCHAR(100) | Not Null | Warehouse Name |

#### `wms_zone` (库区)
| Column | Type | Constraint | Description |
|---|---|---|---|
| id | BIGINT | PK, Auto Inc | Primary Key |
| warehouse_id | BIGINT | FK, Not Null | Warehouse ID |
| code | VARCHAR(50) | Not Null | Zone Code |
| type | VARCHAR(20) | | Type (e.g., STORAGE, RECEIVING, SHIPPING, QC) |
| temperature_zone | VARCHAR(20) | | Temperature Requirement (Normal, Cold, Frozen) |

#### `wms_location` (库位)
| Column | Type | Constraint | Description |
|---|---|---|---|
| id | BIGINT | PK, Auto Inc | Primary Key |
| zone_id | BIGINT | FK, Not Null | Zone ID |
| code | VARCHAR(50) | UK (within Wh), Not Null | Location Code (e.g., A-01-01) |
| type | VARCHAR(20) | | Type (SHELF, PALLET, FLOOR) |
| status | VARCHAR(20) | Default 'AVAILABLE' | AVAILABLE, LOCKED, DISABLED |
| capacity_limit | JSONB | | Weight/Volume limits |

#### `wms_container` (容器/托盘)
| Column | Type | Constraint | Description |
|---|---|---|---|
| id | BIGINT | PK, Auto Inc | Primary Key |
| code | VARCHAR(50) | UK, Not Null | LPN / Container Code |
| type | VARCHAR(20) | | Pallet, Tote, Carton |
| status | VARCHAR(20) | | IN_USE, EMPTY, DAMAGED |

### 2.2 Inbound (入库)

#### `wms_asn` (入库预约单 - Advanced Shipping Notice)
| Column | Type | Constraint | Description |
|---|---|---|---|
| id | BIGINT | PK, Auto Inc | Primary Key |
| asn_no | VARCHAR(50) | UK, Not Null | ASN Number |
| owner_id | BIGINT | FK, Not Null | Owner ID |
| warehouse_id | BIGINT | FK, Not Null | Warehouse ID |
| supplier_code | VARCHAR(50) | | Supplier Code |
| expected_arrival | TIMESTAMP | | Expected Arrival Time |
| status | VARCHAR(20) | | NEW, ARRIVED, RECEIVING, RECEIVED, CLOSED |

#### `wms_asn_detail` (入库单明细)
| Column | Type | Constraint | Description |
|---|---|---|---|
| id | BIGINT | PK, Auto Inc | Primary Key |
| asn_id | BIGINT | FK, Not Null | ASN ID |
| sku_id | BIGINT | FK, Not Null | SKU ID |
| expected_qty | DECIMAL(18,4) | Not Null | Expected Quantity |
| received_qty | DECIMAL(18,4) | Default 0 | Received Quantity |

#### `wms_receipt` (收货记录)
| Column | Type | Constraint | Description |
|---|---|---|---|
| id | BIGINT | PK, Auto Inc | Primary Key |
| asn_detail_id | BIGINT | FK, Not Null | ASN Detail ID |
| sku_id | BIGINT | FK, Not Null | SKU ID |
| quantity | DECIMAL(18,4) | Not Null | Received Quantity |
| batch_no | VARCHAR(50) | | Batch Number |
| production_date | DATE | | Production Date |
| expiry_date | DATE | | Expiry Date |
| container_code | VARCHAR(50) | | LPN / Container Code |
| location_id | BIGINT | FK | Receiving Location ID |

### 2.3 Inventory (库存)

#### `wms_inventory` (库存)
| Column | Type | Constraint | Description |
|---|---|---|---|
| id | BIGINT | PK, Auto Inc | Primary Key |
| warehouse_id | BIGINT | FK, Not Null | Warehouse ID |
| location_id | BIGINT | FK, Not Null | Location ID |
| container_code | VARCHAR(50) | Index | LPN / Container (Optional) |
| sku_id | BIGINT | FK, Not Null | SKU ID |
| batch_no | VARCHAR(50) | | Batch Number |
| quantity | DECIMAL(18,4) | Not Null | On-hand Quantity |
| allocated_qty | DECIMAL(18,4) | Default 0 | Allocated (Reserved) Quantity |
| status | VARCHAR(20) | Default 'GOOD' | GOOD, DAMAGED, QC, FROZEN |
| attributes | JSONB | | Extended attributes (Serial No, etc.) |

#### `wms_inventory_transaction` (库存流水)
| Column | Type | Constraint | Description |
|---|---|---|---|
| id | BIGINT | PK, Auto Inc | Primary Key |
| transaction_type | VARCHAR(50) | Not Null | RECEIPT, PICK, MOVE, ADJUSTMENT |
| sku_id | BIGINT | FK, Not Null | SKU ID |
| from_location_id | BIGINT | FK | Source Location |
| to_location_id | BIGINT | FK | Destination Location |
| quantity | DECIMAL(18,4) | Not Null | Quantity Changed |
| reference_no | VARCHAR(50) | | Order No, ASN No, Task No |
| created_at | TIMESTAMP | Default Now | Transaction Time |

### 2.4 Outbound (出库)

#### `wms_order` (出库订单)
| Column | Type | Constraint | Description |
|---|---|---|---|
| id | BIGINT | PK, Auto Inc | Primary Key |
| order_no | VARCHAR(50) | UK, Not Null | Order Number |
| owner_id | BIGINT | FK, Not Null | Owner ID |
| warehouse_id | BIGINT | FK, Not Null | Warehouse ID |
| type | VARCHAR(20) | | B2B, B2C, TRANSFER |
| status | VARCHAR(20) | | NEW, ALLOCATED, PICKING, PACKED, SHIPPED |
| priority | INT | Default 0 | Priority |
| receiver_info | JSONB | | Name, Address, Phone |

#### `wms_order_detail` (订单明细)
| Column | Type | Constraint | Description |
|---|---|---|---|
| id | BIGINT | PK, Auto Inc | Primary Key |
| order_id | BIGINT | FK, Not Null | Order ID |
| sku_id | BIGINT | FK, Not Null | SKU ID |
| ordered_qty | DECIMAL(18,4) | Not Null | Ordered Quantity |
| allocated_qty | DECIMAL(18,4) | Default 0 | Allocated Quantity |
| picked_qty | DECIMAL(18,4) | Default 0 | Picked Quantity |
| shipped_qty | DECIMAL(18,4) | Default 0 | Shipped Quantity |

#### `wms_wave` (波次)
| Column | Type | Constraint | Description |
|---|---|---|---|
| id | BIGINT | PK, Auto Inc | Primary Key |
| wave_no | VARCHAR(50) | UK, Not Null | Wave Number |
| status | VARCHAR(20) | | CREATED, RELEASED, COMPLETED |

### 2.5 Tasks & Execution (作业与执行)

#### `wms_task` (作业任务)
| Column | Type | Constraint | Description |
|---|---|---|---|
| id | BIGINT | PK, Auto Inc | Primary Key |
| task_no | VARCHAR(50) | UK, Not Null | Task Number |
| type | VARCHAR(20) | Not Null | PUTAWAY, PICK, REPLENISH, COUNT, MOVE |
| status | VARCHAR(20) | | PENDING, ASSIGNED, IN_PROGRESS, COMPLETED |
| priority | INT | Default 0 | Priority |
| sku_id | BIGINT | FK | SKU ID |
| from_location_id | BIGINT | FK | Source Location |
| to_location_id | BIGINT | FK | Destination Location |
| quantity | DECIMAL(18,4) | | Planned Quantity |
| actual_quantity | DECIMAL(18,4) | | Actual Executed Quantity |
| assigned_user_id | BIGINT | | Assigned User/Worker |
| device_code | VARCHAR(50) | | Assigned Device (AGV/Robot) |
| wave_id | BIGINT | FK | Related Wave ID |
| order_id | BIGINT | FK | Related Order ID |

## 3. Design Considerations

1.  **Multi-Owner & Multi-Warehouse**: The schema is designed to support multiple owners and warehouses by including `owner_id` and `warehouse_id` in key tables.
2.  **JSONB Usage**: `specifications`, `attributes`, and `receiver_info` use JSONB to allow flexibility for different product types and business requirements without altering the schema.
3.  **Inventory Precision**: Inventory is tracked at the `location` + `sku` + `batch` + `container` level to ensure high precision.
4.  **Audit Trail**: `wms_inventory_transaction` provides a complete history of all inventory movements for auditing and troubleshooting.
5.  **Task-Driven**: All physical operations (putaway, picking, counting) are driven by the `wms_task` table, which can be integrated with WCS for automation.
