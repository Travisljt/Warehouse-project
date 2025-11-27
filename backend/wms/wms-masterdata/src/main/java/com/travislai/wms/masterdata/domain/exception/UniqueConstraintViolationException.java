package com.travislai.wms.masterdata.domain.exception;

/**
 * Exception thrown when a unique constraint is violated
 */
public class UniqueConstraintViolationException extends BusinessException {
    
    public UniqueConstraintViolationException(String field, String value) {
        super(String.format("Duplicate value '%s' for field '%s'", value, field));
    }
    
    public UniqueConstraintViolationException(String message) {
        super(message);
    }
}
