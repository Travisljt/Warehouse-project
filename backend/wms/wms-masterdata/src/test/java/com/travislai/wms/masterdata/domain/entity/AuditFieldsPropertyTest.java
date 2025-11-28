package com.travislai.wms.masterdata.domain.entity;

import cn.dev33.satoken.stp.StpUtil;
import com.travislai.wms.masterdata.domain.mapper.OwnerMapper;
import net.jqwik.api.*;
import net.jqwik.spring.JqwikSpringSupport;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Property-based tests for audit field auto-fill functionality
 * Tests Properties 1 and 29 from the design document
 */
@JqwikSpringSupport
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.NONE)
@TestPropertySource(properties = {
    "spring.datasource.driver-class-name=org.h2.Driver",
    "spring.datasource.url=jdbc:h2:mem:testdb;MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH",
    "spring.datasource.username=sa",
    "spring.datasource.password=",
    "spring.sql.init.mode=always",
    "spring.sql.init.schema-locations=classpath:schema-test.sql",
    "spring.main.allow-bean-definition-overriding=true"
})
class AuditFieldsPropertyTest {

    @Autowired
    private OwnerMapper ownerMapper;

    /**
     * Feature: master-data-service, Property 1: 创建记录自动填充基础字段
     * Validates: Requirements 1.1, 10.1
     * 
     * For any entity creation operation, the returned record should contain
     * auto-generated ID and properly filled create_date and create_by fields.
     */
    @Property(tries = 100)
    @Label("Property 1: Creating records should auto-fill base fields")
    @Transactional
    void createOwnerShouldAutoFillBaseFields(
            @ForAll("validOwnerCode") String code,
            @ForAll("validOwnerName") String name) {
        
        // Record the time before creation
        LocalDateTime beforeCreate = LocalDateTime.now();
        
        // Create a new owner
        Owner owner = new Owner();
        owner.setCode(code);
        owner.setName(name);
        
        // Insert the owner
        int result = ownerMapper.insert(owner);
        
        // Verify insertion was successful
        assertThat(result).isEqualTo(1);
        
        // Verify ID was auto-generated
        assertThat(owner.getId()).isNotNull();
        assertThat(owner.getId()).isGreaterThan(0L);
        
        // Query the owner back from database to get all auto-filled values
        Owner savedOwner = ownerMapper.selectById(owner.getId());
        assertThat(savedOwner).isNotNull();
        
        // Verify create_date was auto-filled and is recent
        assertThat(savedOwner.getCreateDate()).isNotNull();
        assertThat(savedOwner.getCreateDate())
            .isAfterOrEqualTo(beforeCreate.truncatedTo(ChronoUnit.SECONDS))
            .isBeforeOrEqualTo(LocalDateTime.now().plusSeconds(1));
        
        // Verify create_by was auto-filled (should be "system" when no user is authenticated)
        assertThat(savedOwner.getCreateBy()).isNotNull();
        assertThat(savedOwner.getCreateBy()).isEqualTo("system");
        
        // Verify version was initialized to 0
        assertThat(savedOwner.getVersion()).isNotNull();
        assertThat(savedOwner.getVersion()).isEqualTo(0);
        
        // Verify delete_flag was initialized to 0 (active)
        assertThat(savedOwner.getDeleteFlag()).isNotNull();
        assertThat(savedOwner.getDeleteFlag()).isEqualTo(0);
    }

    /**
     * Feature: master-data-service, Property 29: 审计字段自动填充
     * Validates: Requirements 10.1, 10.5
     * 
     * For any creation operation, create_date should be automatically set to current time,
     * and create_by should be extracted from Sa-Token context (or "system" if not authenticated).
     */
    @Property(tries = 100)
    @Label("Property 29: Audit fields should be auto-filled on creation")
    @Transactional
    void auditFieldsShouldBeAutoFilledOnCreation(
            @ForAll("validOwnerCode") String code,
            @ForAll("validOwnerName") String name) {
        
        LocalDateTime beforeCreate = LocalDateTime.now();
        
        // Create and insert owner
        Owner owner = new Owner();
        owner.setCode(code);
        owner.setName(name);
        ownerMapper.insert(owner);
        
        // Verify create_date is set to current timestamp
        assertThat(owner.getCreateDate()).isNotNull();
        LocalDateTime createDate = owner.getCreateDate();
        long secondsDiff = ChronoUnit.SECONDS.between(beforeCreate, createDate);
        assertThat(secondsDiff).isBetween(-1L, 2L); // Allow 1 second before and 2 seconds after
        
        // Verify create_by is extracted from authentication context
        // When no user is authenticated, it should default to "system"
        assertThat(owner.getCreateBy()).isNotNull();
        String expectedUser = "system"; // Default when not authenticated
        try {
            if (StpUtil.isLogin()) {
                expectedUser = StpUtil.getLoginIdAsString();
            }
        } catch (Exception e) {
            // If Sa-Token throws exception, expectedUser remains "system"
        }
        assertThat(owner.getCreateBy()).isEqualTo(expectedUser);
    }

    /**
     * Feature: master-data-service, Property 3: 乐观锁版本递增
     * Validates: Requirements 1.3, 10.2
     * 
     * For any entity update operation, the version field should increment by 1,
     * and update_date and update_by fields should be updated.
     */
    @Property(tries = 100)
    @Label("Property 3: Update should increment version and fill update fields")
    @Transactional
    void updateShouldIncrementVersionAndFillUpdateFields(
            @ForAll("validOwnerCode") String code,
            @ForAll("validOwnerName") String name,
            @ForAll("validOwnerName") String newName) {
        
        // Create initial owner
        Owner owner = new Owner();
        owner.setCode(code);
        owner.setName(name);
        ownerMapper.insert(owner);
        
        // Query back to get all database-generated values
        Long id = owner.getId();
        Owner savedOwner = ownerMapper.selectById(id);
        
        // Record initial state
        Integer initialVersion = savedOwner.getVersion();
        LocalDateTime createDate = savedOwner.getCreateDate();
        String createBy = savedOwner.getCreateBy();
        
        // Wait a moment to ensure update_date is different
        try {
            Thread.sleep(10);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        LocalDateTime beforeUpdate = LocalDateTime.now();
        
        // Update the owner
        savedOwner.setName(newName);
        int updateResult = ownerMapper.updateById(savedOwner);
        
        // Verify update was successful
        assertThat(updateResult).isEqualTo(1);
        
        // Query back to get updated values
        Owner updatedOwner = ownerMapper.selectById(id);
        
        // Verify version was incremented
        assertThat(updatedOwner.getVersion()).isEqualTo(initialVersion + 1);
        
        // Verify update_date was auto-filled
        assertThat(updatedOwner.getUpdateDate()).isNotNull();
        assertThat(updatedOwner.getUpdateDate())
            .isAfterOrEqualTo(beforeUpdate.truncatedTo(ChronoUnit.SECONDS))
            .isBeforeOrEqualTo(LocalDateTime.now().plusSeconds(1));
        
        // Verify update_by was auto-filled
        assertThat(updatedOwner.getUpdateBy()).isNotNull();
        assertThat(updatedOwner.getUpdateBy()).isEqualTo("system");
        
        // Verify create fields remain unchanged
        assertThat(updatedOwner.getCreateDate()).isEqualTo(createDate);
        assertThat(updatedOwner.getCreateBy()).isEqualTo(createBy);
        
        // Verify ID remains the same
        assertThat(updatedOwner.getId()).isEqualTo(id);
    }

    /**
     * Provides valid owner codes for testing
     */
    @Provide
    Arbitrary<String> validOwnerCode() {
        return Arbitraries.strings()
            .alpha()
            .numeric()
            .ofMinLength(3)
            .ofMaxLength(20)
            .map(String::toUpperCase);
    }

    /**
     * Provides valid owner names for testing
     */
    @Provide
    Arbitrary<String> validOwnerName() {
        return Arbitraries.strings()
            .alpha()
            .numeric()
            .whitespace()
            .ofMinLength(2)
            .ofMaxLength(50)
            .filter(s -> !s.trim().isEmpty());
    }
}
