package com.travislai.wms.masterdata.application.assembler;

import com.travislai.wms.masterdata.application.dto.CreateOwnerRequest;
import com.travislai.wms.masterdata.application.dto.OwnerResponse;
import com.travislai.wms.masterdata.application.dto.UpdateOwnerRequest;
import com.travislai.wms.masterdata.domain.entity.Owner;
import org.springframework.stereotype.Component;

/**
 * Assembler for converting between Owner entity and DTOs
 */
@Component
public class OwnerAssembler {
    
    /**
     * Convert CreateOwnerRequest to Owner entity
     */
    public Owner toEntity(CreateOwnerRequest request) {
        Owner owner = new Owner();
        owner.setCode(request.code());
        owner.setName(request.name());
        return owner;
    }
    
    /**
     * Update Owner entity from UpdateOwnerRequest
     */
    public void updateEntity(Owner owner, UpdateOwnerRequest request) {
        owner.setCode(request.code());
        owner.setName(request.name());
        owner.setVersion(request.version());
    }
    
    /**
     * Convert Owner entity to OwnerResponse
     */
    public OwnerResponse toResponse(Owner owner) {
        return new OwnerResponse(
            owner.getId(),
            owner.getCode(),
            owner.getName(),
            owner.getCreateDate(),
            owner.getCreateBy(),
            owner.getUpdateDate(),
            owner.getUpdateBy(),
            owner.getVersion()
        );
    }
}
