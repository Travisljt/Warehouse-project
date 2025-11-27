package com.travislai.wms.masterdata.domain.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.travislai.wms.masterdata.domain.entity.Owner;

/**
 * Owner domain service interface
 */
public interface OwnerService {
    
    /**
     * Create a new owner
     * @param owner the owner to create
     * @return the created owner with generated ID
     */
    Owner createOwner(Owner owner);
    
    /**
     * Update an existing owner
     * @param id the owner ID
     * @param owner the owner data to update
     * @return the updated owner
     */
    Owner updateOwner(Long id, Owner owner);
    
    /**
     * Delete an owner (logical delete)
     * @param id the owner ID
     */
    void deleteOwner(Long id);
    
    /**
     * Get owner by ID
     * @param id the owner ID
     * @return the owner
     */
    Owner getById(Long id);
    
    /**
     * Get paginated list of owners
     * @param page the page number (1-based)
     * @param size the page size
     * @return page of owners
     */
    Page<Owner> getOwners(int page, int size);
    
    /**
     * Search owners by code or name
     * @param keyword the search keyword
     * @param page the page number (1-based)
     * @param size the page size
     * @return page of matching owners
     */
    Page<Owner> searchOwners(String keyword, int page, int size);
}
