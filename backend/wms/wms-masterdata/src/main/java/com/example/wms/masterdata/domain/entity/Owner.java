package com.example.wms.masterdata.domain.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * Owner (货主) entity
 * Represents a customer or tenant who owns inventory in the warehouse
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("wms_owner")
public class Owner extends BaseEntity {
    
    /**
     * Primary key - auto-generated
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * Owner code - unique identifier
     */
    private String code;
    
    /**
     * Owner name
     */
    private String name;
}
