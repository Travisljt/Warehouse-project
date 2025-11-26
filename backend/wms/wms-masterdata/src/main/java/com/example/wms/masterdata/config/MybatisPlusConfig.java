package com.example.wms.masterdata.config;

import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.OptimisticLockerInnerInterceptor;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * MyBatis-Plus configuration
 * Configures optimistic locking and logical delete
 * Pagination is configured via application.yml global-config
 */
@Configuration
@MapperScan("com.example.wms.masterdata.domain.mapper")
public class MybatisPlusConfig {
    
    /**
     * Configure MyBatis-Plus interceptors
     * - Optimistic locking: prevents concurrent update conflicts using version field
     * - Logical delete: configured via @TableLogic annotation and application.yml
     */
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        
        // Optimistic lock interceptor - handles version field updates
        interceptor.addInnerInterceptor(new OptimisticLockerInnerInterceptor());
        
        return interceptor;
    }
}
