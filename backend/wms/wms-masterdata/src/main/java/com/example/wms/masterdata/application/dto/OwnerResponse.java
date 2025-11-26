package com.example.wms.masterdata.application.dto;

import java.time.LocalDateTime;

/**
 * Response DTO for Owner entity
 * Includes audit fields as per Requirements 10.4
 */
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
