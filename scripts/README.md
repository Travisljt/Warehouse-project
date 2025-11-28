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

**完全重置并初始化数据库脚本**，会自动：
1. 删除所有非系统数据库（保留 postgres, template0, template1）
2. 删除所有非系统用户（保留 postgres 等系统用户）
3. 创建 travis 超级用户（如果不存在则创建，存在则复用）
4. 创建应用数据库
5. 扫描所有后端服务的 `src/main/resources/*_init.sql` 文件（表结构）
6. 扫描所有后端服务的 `src/main/resources/*_insert.sql` 文件（默认数据）
7. 分两个阶段执行：先创建表，再插入数据

⚠️ **警告：此脚本会清空所有数据库和用户，请谨慎使用！**

## 使用方法

### 基本使用

```bash
# 使用默认配置（需要提供postgres超级用户密码）
POSTGRES_PASSWORD=your_postgres_password ./scripts/init-database.sh

# 如果postgres用户密码就是"postgres"
./scripts/init-database.sh
```

### 自定义配置

通过环境变量自定义数据库连接参数：

```bash
# 完整自定义配置
POSTGRES_PASSWORD=your_postgres_password \
DB_HOST=localhost \
DB_PORT=5432 \
DB_NAME=wms_db \
DB_USER=travis \
DB_PASSWORD=39287526 \
./scripts/init-database.sh
```

### 默认配置

| 参数 | 默认值 | 说明 |
|------|--------|------|
| POSTGRES_PASSWORD | postgres | PostgreSQL超级用户密码 |
| DB_HOST | localhost | 数据库主机地址 |
| DB_PORT | 5432 | 数据库端口 |
| DB_NAME | travis_db | 数据库名称 |
| DB_USER | travis | 数据库用户名（超级用户） |
| DB_PASSWORD | 39287526 | travis用户密码 |

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
4. **注意：脚本会自动创建 travis 超级用户，无需手动创建**

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
# 完整示例：完全重置并初始化开发环境数据库
POSTGRES_PASSWORD=your_postgres_password \
DB_HOST=localhost \
DB_PORT=5432 \
DB_NAME=travis_db \
DB_USER=travis \
DB_PASSWORD=39287526 \
./scripts/init-database.sh
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

1. ⚠️ **脚本会删除所有非系统数据库和用户，请确保重要数据已备份**
2. 脚本会自动创建或复用 travis 超级用户
3. 建议仅在开发和测试环境使用，生产环境请谨慎操作
4. 每次运行都会完全重置数据库环境
5. 密码使用 SHA-256 加密存储
6. 需要 postgres 超级用户权限才能执行清理操作
