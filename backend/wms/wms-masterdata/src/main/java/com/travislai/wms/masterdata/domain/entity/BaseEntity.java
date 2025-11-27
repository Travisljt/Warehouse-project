package com.travislai.wms.masterdata.domain.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.Version;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * Base entity class containing common fields for all entities
 * Provides audit trail and soft delete functionality
 */
@Data
public abstract class BaseEntity {
    
    /**
     * Creation timestamp - automatically filled on insert
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createDate;
    
    /**
     * Creator user ID - automatically filled on insert
     */
    @TableField(fill = FieldFill.INSERT)
    private String createBy;
    
    /**
     * Last update timestamp - automatically filled on update
     */
    @TableField(fill = FieldFill.UPDATE)
    private LocalDateTime updateDate;
    
    /**
     * Last updater user ID - automatically filled on update
     */
    @TableField(fill = FieldFill.UPDATE)
    private String updateBy;
    
    /**
     * Logical delete flag: 0=active, 1=deleted
     * Enables soft delete functionality
     */
    @TableLogic
    private Integer deleteFlag;
    
    /**
     * Version number for optimistic locking
     * Automatically incremented on each update
     */
    @Version
    private Integer version;
}
