package com.travislai.wms.masterdata.application.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

/**
 * Generic page request DTO for pagination
 */
public record PageRequest(
    @Min(value = 1, message = "Page number must be at least 1")
    Integer page,
    
    @Min(value = 1, message = "Page size must be at least 1")
    @Max(value = 100, message = "Page size must not exceed 100")
    Integer size
) {
    public PageRequest {
        page = page == null ? 1 : page;
        size = size == null ? 20 : size;
    }
    
    /**
     * Get the offset for database queries
     */
    public long getOffset() {
        return (long) (page - 1) * size;
    }
}
