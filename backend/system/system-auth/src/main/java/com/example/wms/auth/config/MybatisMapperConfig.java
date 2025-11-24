package com.example.wms.auth.config;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@MapperScan("com.example.wms.auth.domain.mapper")
public class MybatisMapperConfig {
}

