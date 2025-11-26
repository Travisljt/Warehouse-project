# 实施计划

- [x] 1. 创建项目结构和基础配置
  - 创建backend/wms目录（如果不存在）
  - 创建backend/wms/wms-masterdata模块目录结构
  - 配置pom.xml依赖（Spring Boot、MyBatis-Plus、Sa-Token等）
  - 创建application.yml配置文件
  - 创建MasterDataServiceApplication启动类
  - _需求: Requirements 7.1, 7.5_

- [x] 2. 实现基础实体和MyBatis-Plus配置
  - [x] 2.1 创建BaseEntity抽象类
    - 定义公共字段（create_date, create_by, update_date, update_by, delete_flag, version）
    - 配置MyBatis-Plus注解（@TableLogic, @Version, @TableField）
    - _需求: Requirements 1.3, 1.4, 10.1, 10.2_
  
  - [x] 2.2 配置MyBatis-Plus全局设置
    - 创建MybatisPlusConfig配置类
    - 配置逻辑删除插件
    - 配置乐观锁插件
    - 配置分页插件
    - _需求: Requirements 7.4_
  
  - [x] 2.3 实现审计字段自动填充
    - 创建AuditMetaObjectHandler实现MetaObjectHandler
    - 实现insertFill方法（填充create_date和create_by）
    - 实现updateFill方法（填充update_date和update_by）
    - 集成Sa-Token获取当前用户
    - _需求: Requirements 10.1, 10.2, 10.5_
  
  - [x] 2.4 编写属性测试：审计字段自动填充
    - **Property 1: 创建记录自动填充基础字段**
    - **Property 29: 审计字段自动填充**
    - **验证需求: Requirements 1.1, 10.1, 10.5**

- [ ] 3. 实现Owner（货主）模块
  - [x] 3.1 创建Owner实体和Mapper
    - 创建Owner实体类继承BaseEntity
    - 创建OwnerMapper接口继承BaseMapper
    - _需求: Requirements 1.1_
  
  - [x] 3.2 创建Owner DTO和Assembler
    - 创建CreateOwnerRequest记录类
    - 创建UpdateOwnerRequest记录类
    - 创建OwnerResponse记录类
    - 创建OwnerAssembler转换类
    - _需求: Requirements 6.2, 10.4_
  
  - [x] 3.3 实现OwnerService业务逻辑
    - 创建OwnerService接口
    - 实现createOwner方法（唯一性检查）
    - 实现updateOwner方法（乐观锁）
    - 实现deleteOwner方法（逻辑删除）
    - 实现getById方法
    - 实现分页查询方法
    - 实现搜索方法（按code或name模糊查询）
    - _需求: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 9.1_
  
  - [ ] 3.4 实现OwnerController REST API
    - 创建OwnerController
    - 实现POST /api/masterdata/owners
    - 实现PUT /api/masterdata/owners/{id}
    - 实现DELETE /api/masterdata/owners/{id}
    - 实现GET /api/masterdata/owners/{id}
    - 实现GET /api/masterdata/owners（分页）
    - 实现GET /api/masterdata/owners/search
    - 添加参数验证注解
    - _需求: Requirements 6.1, 6.6_
  
  - [ ]* 3.5 编写属性测试：Owner唯一性约束
    - **Property 2: 唯一性约束强制执行**
    - **验证需求: Requirements 1.2**
  
  - [ ]* 3.6 编写属性测试：Owner乐观锁
    - **Property 3: 乐观锁版本递增**
    - **验证需求: Requirements 1.3**
  
  - [ ]* 3.7 编写属性测试：Owner逻辑删除
    - **Property 4: 逻辑删除保留记录**
    - **Property 5: 查询过滤已删除记录**
    - **验证需求: Requirements 1.4, 1.5**
  
  - [ ]* 3.8 编写属性测试：Owner模糊查询
    - **Property 27: 模糊查询支持**
    - **验证需求: Requirements 9.1**

- [ ] 4. 实现Contact（联系人）模块
  - [ ] 4.1 创建Contact实体和Mapper
    - 创建Contact实体类
    - 创建ContactMapper接口
    - _需求: Requirements 2.1_
  
  - [ ] 4.2 创建Contact DTO和Assembler
    - 创建CreateContactRequest
    - 创建UpdateContactRequest
    - 创建ContactResponse
    - 创建ContactAssembler
    - _需求: Requirements 6.2_
  
  - [ ] 4.3 实现ContactService业务逻辑
    - 实现createContact方法（验证owner_id存在）
    - 实现主联系人唯一性逻辑（设置is_primary时自动取消其他）
    - 实现updateContact方法
    - 实现deleteContact方法
    - 实现getById方法
    - 实现按owner_id查询方法（按is_primary降序）
    - _需求: Requirements 2.1, 2.2, 2.3, 2.4_
  
  - [ ] 4.4 实现ContactController REST API
    - 创建ContactController
    - 实现POST /api/masterdata/contacts
    - 实现PUT /api/masterdata/contacts/{id}
    - 实现DELETE /api/masterdata/contacts/{id}
    - 实现GET /api/masterdata/contacts/{id}
    - 实现GET /api/masterdata/contacts
    - 实现GET /api/masterdata/contacts/owner/{ownerId}
    - _需求: Requirements 6.1_
  
  - [ ]* 4.5 编写属性测试：Contact外键验证
    - **Property 6: 外键引用验证**
    - **验证需求: Requirements 2.1**
  
  - [ ]* 4.6 编写属性测试：主联系人唯一性
    - **Property 7: 主联系人唯一性**
    - **验证需求: Requirements 2.2**
  
  - [ ]* 4.7 编写属性测试：联系人查询排序
    - **Property 8: 联系人查询排序**
    - **验证需求: Requirements 2.3**

- [ ] 5. 实现ProductCategory（产品类别）模块
  - [ ] 5.1 创建ProductCategory实体和Mapper
    - 创建ProductCategory实体类
    - 创建ProductCategoryMapper接口
    - _需求: Requirements 3.1, 3.2_
  
  - [ ] 5.2 创建ProductCategory DTO和Assembler
    - 创建CreateCategoryRequest
    - 创建UpdateCategoryRequest
    - 创建CategoryResponse
    - 创建CategoryTreeNode（树结构）
    - 创建CategoryAssembler
    - _需求: Requirements 3.3_
  
  - [ ] 5.3 实现ProductCategoryService业务逻辑
    - 实现createCategory方法（计算level和path）
    - 实现根类别创建逻辑（parent_id为null时）
    - 实现子类别创建逻辑（根据parent计算level和path）
    - 实现updateCategory方法（更新parent_id时级联更新后代）
    - 实现deleteCategory方法（检查是否有子类别）
    - 实现getById方法
    - 实现查询所有类别方法（按sort_order排序）
    - 实现构建树结构方法
    - 实现按parent_id查询子类别方法
    - _需求: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_
  
  - [ ] 5.4 实现ProductCategoryController REST API
    - 创建ProductCategoryController
    - 实现POST /api/masterdata/categories
    - 实现PUT /api/masterdata/categories/{id}
    - 实现DELETE /api/masterdata/categories/{id}
    - 实现GET /api/masterdata/categories/{id}
    - 实现GET /api/masterdata/categories
    - 实现GET /api/masterdata/categories/tree
    - 实现GET /api/masterdata/categories/children/{parentId}
    - _需求: Requirements 6.1_
  
  - [ ]* 5.5 编写属性测试：类别层级计算
    - **Property 9: 类别层级计算正确性**
    - **验证需求: Requirements 3.2**
  
  - [ ]* 5.6 编写属性测试：类别树结构
    - **Property 10: 类别树结构完整性**
    - **验证需求: Requirements 3.3**
  
  - [ ]* 5.7 编写属性测试：类别删除约束
    - **Property 11: 有子类别的类别不可删除**
    - **验证需求: Requirements 3.4**
  
  - [ ]* 5.8 编写属性测试：类别层级级联更新
    - **Property 12: 类别层级级联更新**
    - **验证需求: Requirements 3.5**
  
  - [ ]* 5.9 编写属性测试：类别排序
    - **Property 13: 类别排序一致性**
    - **验证需求: Requirements 3.6**

- [ ] 6. 实现Product（产品）模块
  - [ ] 6.1 创建Product实体和Mapper
    - 创建Product实体类
    - 创建ProductMapper接口
    - 添加复合唯一索引支持（owner_id + code）
    - _需求: Requirements 4.1_
  
  - [ ] 6.2 创建Product DTO和Assembler
    - 创建CreateProductRequest
    - 创建UpdateProductRequest
    - 创建ProductResponse（包含ownerName和categoryName）
    - 创建ProductAssembler
    - _需求: Requirements 4.4, 6.2_
  
  - [ ] 6.3 实现JSON验证工具类
    - 创建JsonValidator工具类
    - 实现validateJson方法
    - 创建自定义@ValidJson注解
    - _需求: Requirements 4.2, 4.3, 8.4_
  
  - [ ] 6.4 实现ProductService业务逻辑
    - 实现createProduct方法（验证owner_id和category_id）
    - 实现产品编码唯一性检查（同一owner_id内）
    - 实现JSON字段验证（spec和batch_rules）
    - 实现updateProduct方法
    - 实现deleteProduct方法
    - 实现getById方法（关联查询owner和category）
    - 实现分页查询方法
    - 实现按owner_id查询方法
    - 实现按category_id查询方法
    - 实现多条件搜索方法
    - _需求: Requirements 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 9.2_
  
  - [ ] 6.5 实现ProductController REST API
    - 创建ProductController
    - 实现POST /api/masterdata/products
    - 实现PUT /api/masterdata/products/{id}
    - 实现DELETE /api/masterdata/products/{id}
    - 实现GET /api/masterdata/products/{id}
    - 实现GET /api/masterdata/products（分页）
    - 实现GET /api/masterdata/products/owner/{ownerId}
    - 实现GET /api/masterdata/products/category/{categoryId}
    - 实现GET /api/masterdata/products/search
    - _需求: Requirements 6.1_
  
  - [ ]* 6.6 编写属性测试：产品编码唯一性
    - **Property 14: 产品编码在货主内唯一**
    - **验证需求: Requirements 4.1**
  
  - [ ]* 6.7 编写属性测试：JSON字段验证
    - **Property 15: JSON字段格式验证**
    - **验证需求: Requirements 4.2, 4.3**
  
  - [ ]* 6.8 编写属性测试：产品关联查询
    - **Property 16: 产品查询包含关联信息**
    - **Property 17: 按类别过滤产品**
    - **验证需求: Requirements 4.4, 4.5**
  
  - [ ]* 6.9 编写属性测试：产品多条件查询
    - **Property 28: 多条件过滤支持**
    - **验证需求: Requirements 9.2**

- [ ] 7. 实现Barcode（条码）模块
  - [ ] 7.1 创建Barcode实体和Mapper
    - 创建Barcode实体类
    - 创建BarcodeMapper接口
    - _需求: Requirements 5.1_
  
  - [ ] 7.2 创建Barcode DTO和Assembler
    - 创建CreateBarcodeRequest
    - 创建UpdateBarcodeRequest
    - 创建BarcodeResponse
    - 创建BarcodeLookupResponse（包含产品信息）
    - 创建BarcodeAssembler
    - _需求: Requirements 5.3_
  
  - [ ] 7.3 实现BarcodeService业务逻辑
    - 实现createBarcode方法（验证product_id存在）
    - 实现条码全局唯一性检查
    - 实现主条码唯一性逻辑（设置is_primary时自动取消其他）
    - 实现updateBarcode方法
    - 实现deleteBarcode方法
    - 实现getById方法
    - 实现按barcode值查询方法（返回产品信息）
    - 实现按product_id查询所有条码方法
    - 实现多类型条码支持
    - _需求: Requirements 5.1, 5.2, 5.3, 5.4, 5.5_
  
  - [ ] 7.4 实现BarcodeController REST API
    - 创建BarcodeController
    - 实现POST /api/masterdata/barcodes
    - 实现PUT /api/masterdata/barcodes/{id}
    - 实现DELETE /api/masterdata/barcodes/{id}
    - 实现GET /api/masterdata/barcodes/{id}
    - 实现GET /api/masterdata/barcodes/lookup/{barcode}
    - 实现GET /api/masterdata/barcodes/product/{productId}
    - _需求: Requirements 6.1_
  
  - [ ]* 7.5 编写属性测试：条码唯一性
    - **Property 2: 唯一性约束强制执行**（条码部分）
    - **验证需求: Requirements 5.1**
  
  - [ ]* 7.6 编写属性测试：主条码唯一性
    - **Property 18: 主条码唯一性**
    - **验证需求: Requirements 5.2**
  
  - [ ]* 7.7 编写属性测试：条码查询
    - **Property 19: 条码查询返回产品信息**
    - **验证需求: Requirements 5.3**
  
  - [ ]* 7.8 编写属性测试：多类型条码
    - **Property 20: 多类型条码支持**
    - **验证需求: Requirements 5.5**

- [ ] 8. 实现全局异常处理和验证
  - [ ] 8.1 创建全局异常处理器
    - 创建GlobalExceptionHandler
    - 处理ValidationException（返回400）
    - 处理ResourceNotFoundException（返回404）
    - 处理OptimisticLockException（返回409）
    - 处理BusinessException（返回400）
    - 处理通用Exception（返回500）
    - 统一返回ApiResponse格式
    - _需求: Requirements 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 8.2 创建自定义异常类
    - 创建BusinessException
    - 创建ResourceNotFoundException
    - 创建UniqueConstraintViolationException
    - _需求: Requirements 6.3, 6.4_
  
  - [ ] 8.3 实现通用验证器
    - 创建ValidationUtils工具类
    - 实现必填字段验证
    - 实现字符串长度验证
    - 实现外键引用验证
    - 实现唯一性约束预检查
    - _需求: Requirements 8.1, 8.2, 8.3, 8.5_
  
  - [ ]* 8.4 编写属性测试：验证错误处理
    - **Property 22: 验证错误返回400**
    - **Property 24: 必填字段验证**
    - **Property 25: 字符串长度验证**
    - **验证需求: Requirements 6.3, 8.1, 8.2**
  
  - [ ]* 8.5 编写属性测试：唯一性约束预检查
    - **Property 26: 唯一性约束预检查**
    - **验证需求: Requirements 8.5**

- [ ] 9. 实现分页和响应包装
  - [ ] 9.1 创建分页请求和响应DTO
    - 创建PageRequest记录类（page, size参数）
    - 创建PageResponse记录类（records, total, page, size）
    - _需求: Requirements 6.6_
  
  - [ ] 9.2 在所有列表查询中集成分页
    - 更新OwnerService的查询方法
    - 更新ContactService的查询方法
    - 更新ProductService的查询方法
    - 使用MyBatis-Plus的Page对象
    - _需求: Requirements 6.6_
  
  - [ ]* 9.3 编写属性测试：分页查询
    - **Property 23: 分页查询支持**
    - **验证需求: Requirements 6.6**
  
  - [ ]* 9.4 编写属性测试：API响应格式
    - **Property 21: API响应格式一致性**
    - **Property 30: 审计字段包含在响应中**
    - **验证需求: Requirements 6.2, 10.4**

- [ ] 10. 配置和部署
  - [ ] 10.1 更新父pom.xml
    - 在backend/pom.xml的modules中添加wms/wms-masterdata
    - 如果需要，创建backend/wms/pom.xml作为wms模块的父pom
    - _需求: Requirements 7.5_
  
  - [ ] 10.2 创建启动脚本
    - 更新scripts/start-all-services.sh包含wms-masterdata服务
    - 创建独立的启动脚本
    - _需求: Requirements 7.5_
  
  - [ ] 10.3 创建Dockerfile
    - 创建Dockerfile用于容器化部署
    - 配置端口8082
    - _需求: Requirements 7.5_
  
  - [ ]* 10.4 编写集成测试
    - 使用Testcontainers启动PostgreSQL
    - 测试完整的CRUD流程
    - 测试事务回滚

- [ ] 11. 检查点 - 确保所有测试通过
  - 确保所有测试通过，如有问题请询问用户

- [ ] 12. 文档和示例
  - [ ] 12.1 创建API文档
    - 添加Swagger/OpenAPI注解
    - 生成API文档
  
  - [ ] 12.2 创建README
    - 编写服务说明
    - 添加API使用示例
    - 添加配置说明
