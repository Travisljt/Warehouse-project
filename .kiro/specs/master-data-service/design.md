# 主数据服务设计文档

## 概述

主数据服务（Master Data Service）是WMS系统的核心微服务之一，负责管理货主、联系人、产品类别、产品和条码等主数据实体。该服务采用领域驱动设计（DDD）架构，遵循Spring Boot 3.0 + MyBatis-Plus技术栈，与现有的认证服务保持架构一致性。

服务端口：8082

## 架构设计

### 整体架构

```
backend/
├── wms/                         # WMS业务模块
│   └── wms-masterdata/          # 主数据服务
│       ├── src/main/java/com/example/wms/masterdata/
│       │   ├── MasterDataServiceApplication.java
│       │   ├── application/     # 应用层
│       │   │   ├── controller/  # REST控制器
│       │   │   ├── dto/         # 数据传输对象
│       │   │   └── assembler/   # DTO与实体转换器
│       │   ├── domain/          # 领域层
│       │   │   ├── entity/      # 实体类
│       │   │   ├── mapper/      # MyBatis映射器
│       │   │   └── service/     # 领域服务
│       │   │       └── impl/    # 服务实现
│       │   └── config/          # 配置类
│       └── src/main/resources/
│           ├── application.yml
│           └── mapper/          # MyBatis XML映射文件
└── system/                      # 系统模块（认证、网关等）
    ├── system-auth/
    └── system-gateway/
```

### 分层职责

1. **应用层（Application Layer）**
   - Controller：处理HTTP请求，参数验证，调用领域服务
   - DTO：定义请求和响应数据结构
   - Assembler：实现DTO与实体之间的转换

2. **领域层（Domain Layer）**
   - Entity：领域实体，映射数据库表
   - Mapper：MyBatis-Plus数据访问接口
   - Service：业务逻辑实现，事务管理

3. **配置层（Config Layer）**
   - MyBatis-Plus配置（逻辑删除、乐观锁）
   - 全局异常处理
   - 跨域配置

## 组件和接口

### 1. 实体设计

#### 基础实体（BaseEntity）

所有实体继承的基类，包含公共字段：

```java
@Data
public abstract class BaseEntity {
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createDate;
    
    @TableField(fill = FieldFill.INSERT)
    private String createBy;
    
    @TableField(fill = FieldFill.UPDATE)
    private LocalDateTime updateDate;
    
    @TableField(fill = FieldFill.UPDATE)
    private String updateBy;
    
    @TableLogic
    private Integer deleteFlag;  // 0:存在, 1:删除
    
    @Version
    private Integer version;     // 乐观锁版本号
}
```

#### Owner（货主实体）

```java
@Data
@TableName("wms_owner")
public class Owner extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private String code;  // 唯一编码
    private String name;  // 货主名称
}
```

#### Contact（联系人实体）

```java
@Data
@TableName("wms_contact")
public class Contact extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long ownerId;
    private String contactName;
    private String phone;
    private String mobile;
    private String email;
    private String address;
    private Integer isPrimary;  // 1:主要联系人, 0:否
    private String remark;
}
```

#### ProductCategory（产品类别实体）

```java
@Data
@TableName("wms_product_category")
public class ProductCategory extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private String code;      // 唯一编码
    private String name;      // 类别名称
    private Long parentId;    // 父类别ID
    private Integer level;    // 层级深度
    private String path;      // 层级路径 /1/2/3/
    private Integer sortOrder; // 排序序号
}
```

#### Product（产品实体）

```java
@Data
@TableName("wms_product")
public class Product extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long ownerId;
    private Long categoryId;
    private String code;           // 产品编码（同一货主内唯一）
    private String name;           // 产品名称
    private String shortName;      // 产品简称
    private String unit;           // 基本单位
    private String spec;           // 规格信息（JSON）
    private String batchRules;     // 批次管理规则（JSON）
    private Integer shelfLifeDays; // 保质期天数
    private String storageCondition; // 存储条件
}
```

#### Barcode（条码实体）

```java
@Data
@TableName("wms_barcode")
public class Barcode extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long productId;
    private String barcode;    // 条码值（全局唯一）
    private String type;       // 条码类型
    private Integer isPrimary; // 1:主条码, 0:否
    private String remark;
}
```

### 2. RESTful API设计

#### Owner API

```
POST   /api/masterdata/owners              创建货主
PUT    /api/masterdata/owners/{id}         更新货主
DELETE /api/masterdata/owners/{id}         删除货主（逻辑删除）
GET    /api/masterdata/owners/{id}         查询货主详情
GET    /api/masterdata/owners              分页查询货主列表
GET    /api/masterdata/owners/search       搜索货主（按code或name）
```

#### Contact API

```
POST   /api/masterdata/contacts            创建联系人
PUT    /api/masterdata/contacts/{id}       更新联系人
DELETE /api/masterdata/contacts/{id}       删除联系人
GET    /api/masterdata/contacts/{id}       查询联系人详情
GET    /api/masterdata/contacts            分页查询联系人列表
GET    /api/masterdata/contacts/owner/{ownerId}  查询货主的所有联系人
```

#### ProductCategory API

```
POST   /api/masterdata/categories          创建产品类别
PUT    /api/masterdata/categories/{id}     更新产品类别
DELETE /api/masterdata/categories/{id}     删除产品类别
GET    /api/masterdata/categories/{id}     查询类别详情
GET    /api/masterdata/categories          查询所有类别
GET    /api/masterdata/categories/tree     查询类别树结构
GET    /api/masterdata/categories/children/{parentId}  查询子类别
```

#### Product API

```
POST   /api/masterdata/products            创建产品
PUT    /api/masterdata/products/{id}       更新产品
DELETE /api/masterdata/products/{id}       删除产品
GET    /api/masterdata/products/{id}       查询产品详情
GET    /api/masterdata/products            分页查询产品列表
GET    /api/masterdata/products/owner/{ownerId}  查询货主的产品
GET    /api/masterdata/products/category/{categoryId}  查询类别下的产品
GET    /api/masterdata/products/search     搜索产品
```

#### Barcode API

```
POST   /api/masterdata/barcodes            创建条码
PUT    /api/masterdata/barcodes/{id}       更新条码
DELETE /api/masterdata/barcodes/{id}       删除条码
GET    /api/masterdata/barcodes/{id}       查询条码详情
GET    /api/masterdata/barcodes/lookup/{barcode}  条码查询（返回产品信息）
GET    /api/masterdata/barcodes/product/{productId}  查询产品的所有条码
```

### 3. DTO设计

#### 请求DTO示例

```java
// 创建货主请求
public record CreateOwnerRequest(
    @NotBlank String code,
    @NotBlank String name
) {}

// 创建产品请求
public record CreateProductRequest(
    @NotNull Long ownerId,
    Long categoryId,
    @NotBlank String code,
    @NotBlank String name,
    String shortName,
    @NotBlank String unit,
    String spec,
    String batchRules,
    Integer shelfLifeDays,
    String storageCondition
) {}

// 分页查询请求
public record PageRequest(
    @Min(1) Integer page,
    @Min(1) @Max(100) Integer size
) {
    public PageRequest {
        page = page == null ? 1 : page;
        size = size == null ? 20 : size;
    }
}
```

#### 响应DTO示例

```java
// 货主响应
public record OwnerResponse(
    Long id,
    String code,
    String name,
    LocalDateTime createDate,
    String createBy,
    LocalDateTime updateDate,
    String updateBy,
    Integer version
) {}

// 产品响应（包含关联信息）
public record ProductResponse(
    Long id,
    Long ownerId,
    String ownerName,
    Long categoryId,
    String categoryName,
    String code,
    String name,
    String shortName,
    String unit,
    String spec,
    String batchRules,
    Integer shelfLifeDays,
    String storageCondition,
    LocalDateTime createDate,
    Integer version
) {}

// 分页响应
public record PageResponse<T>(
    List<T> records,
    Long total,
    Integer page,
    Integer size
) {}
```

## 数据模型

### 实体关系图

```
Owner (1) ----< (N) Contact
Owner (1) ----< (N) Product
ProductCategory (1) ----< (N) ProductCategory (自关联)
ProductCategory (1) ----< (N) Product
Product (1) ----< (N) Barcode
```

### 关键约束

1. **唯一性约束**
   - Owner.code：全局唯一
   - ProductCategory.code：全局唯一
   - Product.code：同一owner_id内唯一
   - Barcode.barcode：全局唯一

2. **外键约束**
   - Contact.owner_id → Owner.id
   - Product.owner_id → Owner.id
   - Product.category_id → ProductCategory.id
   - ProductCategory.parent_id → ProductCategory.id
   - Barcode.product_id → Product.id

3. **业务约束**
   - 每个Owner只能有一个主要联系人（is_primary=1）
   - 每个Product只能有一个主条码（is_primary=1）
   - 删除有子类别的ProductCategory时应拒绝操作

## 正确性属性

*属性是系统在所有有效执行中应该保持为真的特征或行为——本质上是关于系统应该做什么的形式化陈述。属性作为人类可读规范和机器可验证正确性保证之间的桥梁。*

### 属性 1: 创建记录自动填充基础字段

*对于任何*实体的创建操作，返回的记录应该包含自动生成的ID和正确填充的create_date、create_by字段。
**验证需求：Requirements 1.1, 10.1**

### 属性 2: 唯一性约束强制执行

*对于任何*具有唯一性约束的字段（Owner.code、ProductCategory.code、Barcode.barcode），尝试创建重复值应该被拒绝并返回验证错误。
**验证需求：Requirements 1.2, 5.1**

### 属性 3: 乐观锁版本递增

*对于任何*实体的更新操作，成功更新后version字段应该比更新前增加1，且update_date和update_by字段应该被更新。
**验证需求：Requirements 1.3, 2.5, 4.6, 10.2**

### 属性 4: 逻辑删除保留记录

*对于任何*实体的删除操作，delete_flag应该被设置为1，但记录应该仍然存在于数据库中，且所有其他字段保持不变。
**验证需求：Requirements 1.4, 10.3**

### 属性 5: 查询过滤已删除记录

*对于任何*查询操作，返回的结果集应该只包含delete_flag=0的记录。
**验证需求：Requirements 1.5**

### 属性 6: 外键引用验证

*对于任何*包含外键的创建操作（如Contact.owner_id、Product.owner_id），如果引用的实体不存在或已被逻辑删除（delete_flag=1），操作应该失败并返回验证错误。
**验证需求：Requirements 2.1, 8.3**

### 属性 7: 主联系人唯一性

*对于任何*Owner，当设置一个Contact为主联系人（is_primary=1）时，该Owner的其他Contact的is_primary应该自动设置为0，确保每个Owner只有一个主联系人。
**验证需求：Requirements 2.2**

### 属性 8: 联系人查询排序

*对于任何*Owner的联系人查询，返回的结果应该按is_primary降序排列（主联系人在前）。
**验证需求：Requirements 2.3**

### 属性 9: 类别层级计算正确性

*对于任何*具有parent_id的ProductCategory创建操作，系统应该正确计算level = parent.level + 1，且path = parent.path + id + "/"。
**验证需求：Requirements 3.2**

### 属性 10: 类别树结构完整性

*对于任何*类别集合，查询树结构应该能够正确构建父子关系，且每个节点的children列表应该包含所有直接子类别。
**验证需求：Requirements 3.3**

### 属性 11: 有子类别的类别不可删除

*对于任何*具有子类别（存在其他类别的parent_id指向它）的ProductCategory，删除操作应该被拒绝并返回错误。
**验证需求：Requirements 3.4**

### 属性 12: 类别层级级联更新

*对于任何*ProductCategory的parent_id更新操作，该类别及其所有后代的level和path字段都应该被重新计算并更新。
**验证需求：Requirements 3.5**

### 属性 13: 类别排序一致性

*对于任何*类别查询，返回的结果应该按sort_order字段排序。
**验证需求：Requirements 3.6**

### 属性 14: 产品编码在货主内唯一

*对于任何*同一owner_id下的Product，code字段应该是唯一的，尝试创建重复code应该被拒绝。
**验证需求：Requirements 4.1**

### 属性 15: JSON字段格式验证

*对于任何*Product的spec或batch_rules字段，如果提供的值不是有效的JSON格式，创建或更新操作应该被拒绝并返回验证错误。
**验证需求：Requirements 4.2, 4.3, 8.4**

### 属性 16: 产品查询包含关联信息

*对于任何*Product查询，返回的结果应该包含关联的Owner名称和ProductCategory名称。
**验证需求：Requirements 4.4**

### 属性 17: 按类别过滤产品

*对于任何*category_id的产品查询，返回的所有Product记录的category_id应该等于查询参数。
**验证需求：Requirements 4.5**

### 属性 18: 主条码唯一性

*对于任何*Product，当设置一个Barcode为主条码（is_primary=1）时，该Product的其他Barcode的is_primary应该自动设置为0，确保每个Product只有一个主条码。
**验证需求：Requirements 5.2**

### 属性 19: 条码查询返回产品信息

*对于任何*有效的barcode值查询，应该能够返回关联的Product完整信息。
**验证需求：Requirements 5.3**

### 属性 20: 多类型条码支持

*对于任何*Product，应该能够创建多个不同type的Barcode记录。
**验证需求：Requirements 5.5**

### 属性 21: API响应格式一致性

*对于任何*API响应，都应该使用ApiResponse包装器，包含success、message和data字段。
**验证需求：Requirements 6.2**

### 属性 22: 验证错误返回400

*对于任何*包含无效数据的请求（缺少必填字段、字段超长、格式错误等），应该返回HTTP 400状态码和详细错误信息。
**验证需求：Requirements 6.3, 8.1, 8.2**

### 属性 23: 分页查询支持

*对于任何*列表查询API，应该支持page和size参数，并返回包含records、total、page、size的分页响应。
**验证需求：Requirements 6.6**

### 属性 24: 必填字段验证

*对于任何*创建或更新请求，所有标记为@NotNull或@NotBlank的字段如果缺失或为空，应该返回验证错误。
**验证需求：Requirements 8.1**

### 属性 25: 字符串长度验证

*对于任何*字符串字段，如果输入值超过数据库schema定义的最大长度，应该返回验证错误。
**验证需求：Requirements 8.2**

### 属性 26: 唯一性约束预检查

*对于任何*具有唯一性约束的字段，在执行数据库操作前应该先检查唯一性，如果违反约束应该返回业务错误而不是数据库异常。
**验证需求：Requirements 8.5**

### 属性 27: 模糊查询支持

*对于任何*Owner的搜索查询，应该支持按code或name进行部分匹配（LIKE查询）。
**验证需求：Requirements 9.1**

### 属性 28: 多条件过滤支持

*对于任何*Product查询，应该支持同时按owner_id、category_id、code、name等多个条件进行过滤。
**验证需求：Requirements 9.2**

### 属性 29: 审计字段自动填充

*对于任何*创建操作，create_date应该自动设置为当前时间，create_by应该从Sa-Token上下文中提取当前用户标识。
**验证需求：Requirements 10.1, 10.5**

### 属性 30: 审计字段包含在响应中

*对于任何*查询响应DTO，应该包含create_date、create_by、update_date、update_by等审计字段。
**验证需求：Requirements 10.4**

## 错误处理

### 异常类型

1. **业务异常（BusinessException）**
   - 唯一性约束冲突
   - 外键引用不存在
   - 业务规则违反（如删除有子类别的类别）

2. **验证异常（ValidationException）**
   - 必填字段缺失
   - 字段格式错误
   - 字段长度超限
   - JSON格式错误

3. **乐观锁异常（OptimisticLockException）**
   - 版本冲突

4. **资源不存在异常（ResourceNotFoundException）**
   - 查询的ID不存在

### 错误响应格式

```json
{
  "success": false,
  "message": "错误描述",
  "data": {
    "errorCode": "UNIQUE_CONSTRAINT_VIOLATION",
    "field": "code",
    "value": "OWNER001"
  }
}
```

### HTTP状态码映射

- 200: 操作成功
- 400: 请求参数验证失败
- 404: 资源不存在
- 409: 乐观锁冲突或唯一性约束冲突
- 500: 服务器内部错误

## 测试策略

### 单元测试

使用JUnit 5和Mockito进行单元测试，覆盖：

1. **Service层测试**
   - 业务逻辑正确性
   - 异常处理
   - 事务边界

2. **Controller层测试**
   - 请求参数验证
   - 响应格式
   - HTTP状态码

3. **Assembler测试**
   - DTO与实体转换正确性

### 集成测试

使用Spring Boot Test和Testcontainers进行集成测试：

1. **数据库集成测试**
   - 使用Testcontainers启动PostgreSQL容器
   - 测试完整的CRUD操作
   - 测试事务回滚

2. **API集成测试**
   - 使用MockMvc测试完整的HTTP请求响应
   - 测试认证和授权

### 属性测试（Property-Based Testing）

使用jqwik框架进行属性测试，验证正确性属性：

- 测试框架：jqwik 1.7.4
- 每个属性测试运行至少100次迭代
- 每个属性测试使用注释标记对应的设计文档属性编号

示例：
```java
@Property
@Label("Feature: master-data-service, Property 1: 创建记录自动填充基础字段")
void createOwnerShouldAutoFillBaseFields(@ForAll("validOwnerCode") String code,
                                         @ForAll("validOwnerName") String name) {
    // 测试实现
}
```

## 技术栈

- **框架**: Spring Boot 3.0.13
- **ORM**: MyBatis-Plus 3.5.9
- **数据库**: PostgreSQL 42.7.4
- **认证**: Sa-Token 1.38.0
- **验证**: Jakarta Validation
- **测试**: JUnit 5, Mockito, jqwik
- **构建**: Maven

## 配置说明

### application.yml

```yaml
server:
  port: 8082

spring:
  application:
    name: master-data-service
  datasource:
    url: jdbc:postgresql://localhost:5432/wms
    username: wms_user
    password: wms_password
    driver-class-name: org.postgresql.Driver
  
mybatis-plus:
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
  global-config:
    db-config:
      logic-delete-field: deleteFlag
      logic-delete-value: 1
      logic-not-delete-value: 0
      id-type: auto
    banner: false

sa-token:
  token-name: Authorization
  timeout: 2592000
  activity-timeout: -1
  is-concurrent: true
  is-share: false
  token-style: uuid
```

### MyBatis-Plus配置

```java
@Configuration
public class MybatisPlusConfig {
    
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        
        // 乐观锁插件
        interceptor.addInnerInterceptor(new OptimisticLockerInnerInterceptor());
        
        // 分页插件
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.POSTGRE_SQL));
        
        return interceptor;
    }
    
    @Bean
    public MetaObjectHandler metaObjectHandler() {
        return new AuditMetaObjectHandler();
    }
}
```

### 审计字段自动填充

```java
@Component
public class AuditMetaObjectHandler implements MetaObjectHandler {
    
    @Override
    public void insertFill(MetaObject metaObject) {
        this.strictInsertFill(metaObject, "createDate", LocalDateTime.class, LocalDateTime.now());
        this.strictInsertFill(metaObject, "createBy", String.class, getCurrentUser());
    }
    
    @Override
    public void updateFill(MetaObject metaObject) {
        this.strictUpdateFill(metaObject, "updateDate", LocalDateTime.class, LocalDateTime.now());
        this.strictUpdateFill(metaObject, "updateBy", String.class, getCurrentUser());
    }
    
    private String getCurrentUser() {
        try {
            return StpUtil.getLoginIdAsString();
        } catch (Exception e) {
            return "system";
        }
    }
}
```

## 部署说明

### Maven构建

```bash
cd backend/wms/wms-masterdata
mvn clean package
```

### 运行服务

```bash
java -jar target/wms-masterdata-0.1.0-SNAPSHOT.jar
```

### Docker部署

```dockerfile
FROM openjdk:17-slim
WORKDIR /app
COPY target/wms-masterdata-0.1.0-SNAPSHOT.jar app.jar
EXPOSE 8082
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## 性能考虑

1. **数据库索引**
   - 所有外键字段建立索引
   - delete_flag字段建立索引
   - 唯一性约束字段自动建立唯一索引

2. **查询优化**
   - 使用MyBatis-Plus的分页插件避免全表扫描
   - 关联查询使用JOIN而不是N+1查询
   - 条码查询使用索引确保快速响应

3. **缓存策略**
   - 产品类别树结构可以考虑缓存
   - 货主信息可以考虑缓存
   - 使用Spring Cache抽象

## 安全考虑

1. **认证授权**
   - 所有API需要Sa-Token认证
   - 使用StpUtil获取当前用户信息

2. **数据隔离**
   - 货主数据按owner_id隔离
   - 查询时自动过滤已删除数据

3. **SQL注入防护**
   - 使用MyBatis-Plus的参数化查询
   - 避免字符串拼接SQL

4. **输入验证**
   - 使用Jakarta Validation进行参数验证
   - 自定义验证器验证JSON格式

