package com.example.wms.masterdata.config;

import cn.dev33.satoken.stp.StpUtil;
import com.baomidou.mybatisplus.core.handlers.MetaObjectHandler;
import org.apache.ibatis.reflection.MetaObject;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * Audit field auto-fill handler
 * Automatically populates create_date, create_by, update_date, update_by fields
 */
@Component
public class AuditMetaObjectHandler implements MetaObjectHandler {
    
    /**
     * Auto-fill logic for INSERT operations
     * Fills create_date with current timestamp and create_by with current user
     */
    @Override
    public void insertFill(MetaObject metaObject) {
        this.strictInsertFill(metaObject, "createDate", LocalDateTime.class, LocalDateTime.now());
        this.strictInsertFill(metaObject, "createBy", String.class, getCurrentUser());
    }
    
    /**
     * Auto-fill logic for UPDATE operations
     * Fills update_date with current timestamp and update_by with current user
     */
    @Override
    public void updateFill(MetaObject metaObject) {
        this.strictUpdateFill(metaObject, "updateDate", LocalDateTime.class, LocalDateTime.now());
        this.strictUpdateFill(metaObject, "updateBy", String.class, getCurrentUser());
    }
    
    /**
     * Get current user from Sa-Token authentication context
     * Falls back to "system" if no user is authenticated
     */
    private String getCurrentUser() {
        try {
            return StpUtil.getLoginIdAsString();
        } catch (Exception e) {
            // Return "system" for operations without authentication context
            // (e.g., system initialization, background jobs)
            return "system";
        }
    }
}
