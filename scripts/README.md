# WMS 数据库初始化脚本

## 概述

本目录包含 WMS 系统的数据库初始化脚本，用于自动创建数据库表结构并填充默认数据。

## 文件命名规范

所有 SQL 文件遵循以下命名规范：

- `{service_name}_init.sql` - 创建表结构（DDL）
- `{service_name}_insert.sql` - 插入默认数据（DML）

例如：
- `auth_init.sql` - 认证服务表结构
- `auth_insert.sql` - 认证服务默认数据
- `master_data_init.sql` - 主数据服务表结构
- `master_data_insert.sql` - 主数据服务默认数据

## 脚本说明

### init-database.sh

**智能数据库初始化脚本（遵循开闭原则）**

**设计原则：**
- **开放扩展**：添加新服务时，只需在服务的 `src/main/resources/` 目录下创建 `{db_name}_init.sql` 文件，脚本会自动发现并处理
- **关闭修改**：无需修改此脚本即可支持新的数据库和服务

**执行步骤：**
1. 创建 travis 超级用户（如果不存在则创建，存在则复用）
2. 自动发现所有 `*_init.sql` 文件，从文件名提取数据库名
3. 对每个发现的数据库：
   - Drop 并重新创建数据库
   - 创建对应的数据库用户（用户名=数据库名，密码=数据库名）
   - 执行 `{db_name}_init.sql`（建表）
   - 执行 `{db_name}_insert.sql`（插入数据，如果存在）

**命名规则：**
- `{db_name}_init.sql` → 数据库名为 `{db_name}`
- 例如：`auth_init.sql` → 数据库名为 `auth`，用户名为 `auth`，密码为 `auth`
- 例如：`master_data_init.sql` → 数据库名为 `master_data`，用户名为 `master_data`，密码为 `master_data`

## 使用方法

### 基本使用

```bash
# 使用默认配置
./scripts/init-database.sh

# 如果postgres用户密码不是默认的"postgres"
POSTGRES_PASSWORD=your_postgres_password ./scripts/init-database.sh
```

### 自定义配置

```bash
# 自定义数据库主机和端口
POSTGRES_PASSWORD=your_password \
DB_HOST=192.168.1.100 \
DB_PORT=5432 \
./scripts/init-database.sh
```

### 默认配置

| 参数 | 默认值 | 说明 |
|------|--------|------|
| POSTGRES_PASSWORD | postgres | PostgreSQL超级用户密码 |
| DB_HOST | localhost | 数据库主机地址 |
| DB_PORT | 5432 | 数据库端口 |

### 自动创建的用户

| 用户名 | 密码 | 权限 | 说明 |
|--------|------|------|------|
| travis | 39287526 | SUPERUSER | 系统超级用户 |
| auth | auth | 数据库权限 | auth数据库用户 |
| master_data | master_data | 数据库权限 | master_data数据库用户 |
| ... | ... | ... | 根据*_init.sql自动创建 |

## 默认数据

### 系统认证服务 (system-auth)

执行 `auth_init.sql` 和 `auth_insert.sql` 后会创建：

**默认管理员账号：**
- 用户名：`admin`
- 密码：`admin`
- 角色：超级管理员

**系统表：**
- `sys_user` - 用户表
- `sys_role` - 角色表
- `sys_menu` - 菜单表
- `sys_user_role` - 用户角色关联表
- `sys_role_menu` - 角色菜单关联表

### 主数据服务 (wms-masterdata)

执行 `master_data_init.sql` 和 `master_data_insert.sql` 后会创建：

**默认数据：**
- 默认货主：`DEFAULT`
- 默认产品类别：通用类别、食品类、电子产品

**主数据表：**
- `wms_owner` - 货主表
- `wms_contact` - 联系方式表
- `wms_product_category` - 产品类别表
- `wms_product` - 产品表
- `wms_barcode` - 条码映射表

## 前置条件

1. PostgreSQL 已安装并运行
2. 知道 postgres 超级用户的密码
3. 已安装 `psql` 命令行工具

## 开闭原则设计说明

**开放扩展（Open for Extension）：**
- 添加新服务时，只需在服务的 `src/main/resources/` 目录创建 `{db_name}_init.sql` 文件
- 脚本会自动发现新的数据库并完成初始化
- 无需修改任何配置文件或脚本代码

**关闭修改（Closed for Modification）：**
- 脚本核心逻辑不需要改动
- 通过文件命名约定实现自动发现机制
- 数据库名、用户名、密码都从文件名自动推导

**示例：添加新服务**
```bash
# 1. 创建新服务的SQL文件
backend/billing/billing-service/src/main/resources/
├── billing_init.sql      # 脚本自动发现，创建billing数据库
└── billing_insert.sql    # 可选，插入默认数据

# 2. 运行脚本（无需修改）
./scripts/init-database.sh

# 3. 自动完成：
#    - 创建 billing 数据库
#    - 创建 billing 用户（密码：billing）
#    - 执行 billing_init.sql
#    - 执行 billing_insert.sql
```

## 故障排查

### 连接失败

如果出现连接失败，请检查：
1. PostgreSQL 服务是否运行
2. 数据库连接参数是否正确
3. 用户权限是否足够
4. 防火墙是否允许连接

### 执行失败

如果某个 schema 执行失败：
1. 脚本会继续执行其他 schema
2. 查看错误信息定位问题
3. 可以手动执行失败的 SQL 文件进行调试

## 添加新服务的 Schema

要为新服务添加数据库初始化脚本：

1. 在服务的 `src/main/resources/` 目录下创建两个文件：
   - `{service_name}_init.sql` - 表结构定义
   - `{service_name}_insert.sql` - 默认数据（可选）

2. 在 `*_init.sql` 中：
   - 使用 `CREATE TABLE IF NOT EXISTS` 确保幂等性
   - 只包含 DDL 语句（CREATE TABLE, CREATE INDEX 等）
   - 添加清晰的注释说明

3. 在 `*_insert.sql` 中：
   - 使用 `ON CONFLICT DO NOTHING` 避免重复插入
   - 只包含 DML 语句（INSERT）
   - 插入必要的默认数据

4. 运行 `init-database.sh` 脚本会自动发现并按顺序执行

## 示例

```bash
# 示例1：使用默认配置初始化所有数据库
./scripts/init-database.sh

# 示例2：指定postgres密码
POSTGRES_PASSWORD=mypassword ./scripts/init-database.sh

# 示例3：连接远程数据库
POSTGRES_PASSWORD=mypassword \
DB_HOST=192.168.1.100 \
DB_PORT=5432 \
./scripts/init-database.sh
```

**执行输出示例：**
```
========================================
  WMS Database Initialization
  (Open-Closed Principle Design)
========================================

Step 1: Setup Travis User
  ✓ Superuser 'travis' created

Step 2: Discover Databases
  Found database: auth (from auth_init.sql)
  Found database: master_data (from master_data_init.sql)
  Discovered 2 database(s)

Step 3: Initialize Databases
  Database: auth
    ✓ Database 'auth' recreated
    ✓ User 'auth' created (password: auth)
    ✓ Successfully executed auth_init.sql
    ✓ Successfully executed auth_insert.sql
  
  Database: master_data
    ✓ Database 'master_data' recreated
    ✓ User 'master_data' created (password: master_data)
    ✓ Successfully executed master_data_init.sql
    No insert file found (optional)
```

## 文件结构

```
backend/
├── system/
│   └── system-auth/
│       └── src/main/resources/
│           ├── auth_init.sql      # 认证服务表结构
│           └── auth_insert.sql    # 认证服务默认数据
└── wms/
    └── wms-masterdata/
        └── src/main/resources/
            ├── master_data_init.sql    # 主数据服务表结构
            └── master_data_insert.sql  # 主数据服务默认数据

scripts/
├── init-database.sh              # 数据库初始化脚本
├── 01_master_data_init.sql      # 旧版本（已废弃）
└── README.md                     # 本文档
```

## 注意事项

1. ⚠️ **脚本会 DROP 并重新创建所有发现的数据库，请确保重要数据已备份**
2. 脚本会自动创建或复用 travis 超级用户
3. 每个数据库的用户名和密码默认都是数据库名本身
4. 建议仅在开发和测试环境使用，生产环境请谨慎操作
5. 密码使用 SHA-256 加密存储
6. 需要 postgres 超级用户权限才能执行
