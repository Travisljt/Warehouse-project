package com.travislai.wms.auth.config;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@MapperScan("com.travislai.wms.auth.domain.mapper")
public class MybatisMapperConfig {
}

