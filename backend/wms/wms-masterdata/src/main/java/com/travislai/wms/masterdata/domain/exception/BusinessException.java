package com.travislai.wms.masterdata.domain.exception;

/**
 * Business exception for domain logic violations
 */
public class BusinessException extends RuntimeException {
    
    public BusinessException(String message) {
        super(message);
    }
    
    public BusinessException(String message, Throwable cause) {
        super(message, cause);
    }
}
