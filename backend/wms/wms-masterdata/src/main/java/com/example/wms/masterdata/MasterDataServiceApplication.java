package com.example.wms.masterdata;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Master Data Service Application
 * 
 * This service manages core master data entities including:
 * - Owners (货主)
 * - Contacts
 * - Product Categories
 * - Products
 * - Barcodes
 */
@SpringBootApplication(scanBasePackages = "com.example.wms")
public class MasterDataServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(MasterDataServiceApplication.class, args);
    }
}
