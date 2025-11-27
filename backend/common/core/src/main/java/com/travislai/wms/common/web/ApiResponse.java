package com.travislai.wms.common.web;

import com.fasterxml.jackson.annotation.JsonInclude;

/**
 * 通用 API 返回包装，便于前后端约定一致。
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record ApiResponse<T>(boolean success, String message, T data) {

    public static <T> ApiResponse<T> ok(T data) {
        return new ApiResponse<>(true, "OK", data);
    }

    public static ApiResponse<Void> ok() {
        return new ApiResponse<>(true, "OK", null);
    }

    public static ApiResponse<Void> fail(String message) {
        return new ApiResponse<>(false, message, null);
    }

    public static <T> ApiResponse<T> fail(String message, T data) {
        return new ApiResponse<>(false, message, data);
    }
}

