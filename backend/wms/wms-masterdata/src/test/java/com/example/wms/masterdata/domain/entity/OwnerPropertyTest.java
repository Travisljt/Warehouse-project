package com.travislai.wms.masterdata.domain.entity;

import com.travislai.wms.masterdata.domain.exception.UniqueConstraintViolationException;
import com.travislai.wms.masterdata.domain.mapper.OwnerMapper;
import com.travislai.wms.masterdata.domain.service.OwnerService;
import net.jqwik.api.*;
import net.jqwik.spring.JqwikSpringSupport;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * Property-based tests for Owner uniqueness constraints
 * Tests Property 2 from the design document
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
class OwnerPropertyTest {

    @Autowired
    private OwnerService ownerService;

    @Autowired
    private OwnerMapper ownerMapper;

    /**
     * Feature: master-data-service, Property 2: 唯一性约束强制执行
     * Validates: Requirements 1.2
     * 
     * The system must reject any attempt to create an owner with a code that already exists.
     */
    @Property(tries = 50)
    @Label("Property 2: Owner code must be unique")
    @Transactional
    void uniqueCodeConstraintShouldBeEnforced(
            @ForAll("validOwnerCode") String code,
            @ForAll("validOwnerName") String name1,
            @ForAll("validOwnerName") String name2) {
        
        // Create first owner
        Owner owner1 = new Owner();
        owner1.setCode(code);
        owner1.setName(name1);
        ownerService.createOwner(owner1);
        
        // Attempt to create second owner with same code
        Owner owner2 = new Owner();
        owner2.setCode(code);
        owner2.setName(name2);
        
        // Verify that UniqueConstraintViolationException is thrown
        assertThatThrownBy(() -> ownerService.createOwner(owner2))
            .isInstanceOf(UniqueConstraintViolationException.class);
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
