package com.travislai.wms.masterdata.application.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * Request DTO for updating an existing Owner
 */
public record UpdateOwnerRequest(
    @NotBlank(message = "Owner code is required")
    @Size(max = 50, message = "Owner code must not exceed 50 characters")
    String code,
    
    @NotBlank(message = "Owner name is required")
    @Size(max = 200, message = "Owner name must not exceed 200 characters")
    String name,
    
    @NotNull(message = "Version is required for optimistic locking")
    Integer version
) {}
