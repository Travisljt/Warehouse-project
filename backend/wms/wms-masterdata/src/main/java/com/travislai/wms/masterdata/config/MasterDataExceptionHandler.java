package com.travislai.wms.masterdata.config;

import com.baomidou.mybatisplus.core.exceptions.MybatisPlusException;
import com.travislai.wms.common.web.ApiResponse;
import com.travislai.wms.masterdata.domain.exception.BusinessException;
import com.travislai.wms.masterdata.domain.exception.ResourceNotFoundException;
import com.travislai.wms.masterdata.domain.exception.UniqueConstraintViolationException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.OptimisticLockingFailureException;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * Exception handler specific to Master Data Service
 */
@RestControllerAdvice
public class MasterDataExceptionHandler {
    
    private static final Logger log = LoggerFactory.getLogger(MasterDataExceptionHandler.class);
    
    @ExceptionHandler(ResourceNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ApiResponse<Void> handleResourceNotFound(ResourceNotFoundException ex) {
        log.warn("Resource not found: {}", ex.getMessage());
        return ApiResponse.fail(ex.getMessage());
    }
    
    @ExceptionHandler(UniqueConstraintViolationException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public ApiResponse<Void> handleUniqueConstraintViolation(UniqueConstraintViolationException ex) {
        log.warn("Unique constraint violation: {}", ex.getMessage());
        return ApiResponse.fail(ex.getMessage());
    }
    
    @ExceptionHandler(BusinessException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ApiResponse<Void> handleBusinessException(BusinessException ex) {
        log.warn("Business exception: {}", ex.getMessage());
        return ApiResponse.fail(ex.getMessage());
    }
    
    @ExceptionHandler(OptimisticLockingFailureException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public ApiResponse<Void> handleOptimisticLock(OptimisticLockingFailureException ex) {
        log.warn("Optimistic lock conflict: {}", ex.getMessage());
        return ApiResponse.fail("Version conflict - the record has been modified by another user");
    }
    
    @ExceptionHandler(MybatisPlusException.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ApiResponse<Void> handleMybatisPlusException(MybatisPlusException ex) {
        log.error("MyBatis-Plus exception", ex);
        return ApiResponse.fail("Database operation failed");
    }
}
