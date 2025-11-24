package com.example.wms.common.config;

import cn.dev33.satoken.filter.SaServletFilter;
import cn.dev33.satoken.router.SaRouter;
import cn.dev33.satoken.stp.StpUtil;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Sa-Token 全局过滤器配置，排除开放接口，其余统一鉴权。
 */
@Configuration
public class SaTokenConfigure {

    @Bean
    public SaServletFilter saServletFilter() {
        return new SaServletFilter()
                .addInclude("/**")
                .addExclude("/api/auth/login", "/actuator/**")
                .setAuth(obj -> SaRouter.match("/**", r -> StpUtil.checkLogin()));
    }
}

