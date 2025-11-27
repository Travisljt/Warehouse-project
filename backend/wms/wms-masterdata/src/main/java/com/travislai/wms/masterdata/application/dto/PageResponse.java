package com.travislai.wms.masterdata.application.dto;

import java.util.List;

/**
 * Generic page response DTO for paginated results
 */
public record PageResponse<T>(
    List<T> records,
    Long total,
    Integer page,
    Integer size
) {}
