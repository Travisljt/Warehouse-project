package com.travislai.wms.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Gateway Service Application
 * 
 * This service acts as the API gateway for the WMS system.
 */
@SpringBootApplication(scanBasePackages = "com.travislai.wms")
public class GatewayServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(GatewayServiceApplication.class, args);
    }
}

