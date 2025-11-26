package com.example.wms.masterdata.domain.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.wms.masterdata.domain.entity.Owner;
import com.example.wms.masterdata.domain.exception.ResourceNotFoundException;
import com.example.wms.masterdata.domain.exception.UniqueConstraintViolationException;
import com.example.wms.masterdata.domain.mapper.OwnerMapper;
import com.example.wms.masterdata.domain.service.OwnerService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

/**
 * Owner service implementation
 */
@Service
public class OwnerServiceImpl implements OwnerService {
    
    private final OwnerMapper ownerMapper;
    
    public OwnerServiceImpl(OwnerMapper ownerMapper) {
        this.ownerMapper = ownerMapper;
    }
    
    @Override
    @Transactional
    public Owner createOwner(Owner owner) {
        // Check uniqueness of code (Requirements 1.2, 8.5)
        checkCodeUniqueness(owner.getCode(), null);
        
        // Insert owner - base fields will be auto-filled by MetaObjectHandler
        ownerMapper.insert(owner);
        
        return owner;
    }
    
    @Override
    @Transactional
    public Owner updateOwner(Long id, Owner owner) {
        // Check if owner exists
        Owner existing = getById(id);
        
        // Check uniqueness of code if changed (Requirements 1.2, 8.5)
        if (!existing.getCode().equals(owner.getCode())) {
            checkCodeUniqueness(owner.getCode(), id);
        }
        
        // Set ID for update
        owner.setId(id);
        
        // Update owner - optimistic lock will be checked automatically
        // update_date and update_by will be auto-filled by MetaObjectHandler
        int updated = ownerMapper.updateById(owner);
        
        if (updated == 0) {
            throw new RuntimeException("Update failed - possible version conflict");
        }
        
        return ownerMapper.selectById(id);
    }
    
    @Override
    @Transactional
    public void deleteOwner(Long id) {
        // Check if owner exists
        Owner owner = getById(id);
        
        // Logical delete - delete_flag will be set to 1 automatically
        ownerMapper.deleteById(id);
    }
    
    @Override
    public Owner getById(Long id) {
        Owner owner = ownerMapper.selectById(id);
        if (owner == null) {
            throw new ResourceNotFoundException("Owner", id);
        }
        return owner;
    }
    
    @Override
    public Page<Owner> getOwners(int page, int size) {
        Page<Owner> pageRequest = new Page<>(page, size);
        return ownerMapper.selectPage(pageRequest, null);
    }
    
    @Override
    public Page<Owner> searchOwners(String keyword, int page, int size) {
        Page<Owner> pageRequest = new Page<>(page, size);
        
        if (!StringUtils.hasText(keyword)) {
            return ownerMapper.selectPage(pageRequest, null);
        }
        
        // Search by code or name using LIKE (Requirements 9.1)
        LambdaQueryWrapper<Owner> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.like(Owner::getCode, keyword)
                   .or()
                   .like(Owner::getName, keyword);
        
        return ownerMapper.selectPage(pageRequest, queryWrapper);
    }
    
    /**
     * Check if owner code is unique
     * @param code the code to check
     * @param excludeId the ID to exclude from check (for updates)
     */
    private void checkCodeUniqueness(String code, Long excludeId) {
        LambdaQueryWrapper<Owner> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Owner::getCode, code);
        
        if (excludeId != null) {
            queryWrapper.ne(Owner::getId, excludeId);
        }
        
        Long count = ownerMapper.selectCount(queryWrapper);
        if (count > 0) {
            throw new UniqueConstraintViolationException("code", code);
        }
    }
}
