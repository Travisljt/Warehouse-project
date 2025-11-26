package com.example.wms.masterdata.application.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Request DTO for creating a new Owner
 */
public record CreateOwnerRequest(
    @NotBlank(message = "Owner code is required")
    @Size(max = 50, message = "Owner code must not exceed 50 characters")
    String code,
    
    @NotBlank(message = "Owner name is required")
    @Size(max = 200, message = "Owner name must not exceed 200 characters")
    String name
) {}
