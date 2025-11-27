package com.travislai.wms.masterdata.application.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.travislai.wms.common.web.ApiResponse;
import com.travislai.wms.masterdata.application.assembler.OwnerAssembler;
import com.travislai.wms.masterdata.application.dto.CreateOwnerRequest;
import com.travislai.wms.masterdata.application.dto.OwnerResponse;
import com.travislai.wms.masterdata.application.dto.PageResponse;
import com.travislai.wms.masterdata.application.dto.UpdateOwnerRequest;
import com.travislai.wms.masterdata.domain.entity.Owner;
import com.travislai.wms.masterdata.domain.service.OwnerService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Owner REST API Controller
 * Provides endpoints for managing owner (货主) entities
 */
@RestController
@RequestMapping("/api/masterdata/owners")
@Validated
public class OwnerController {
    
    private final OwnerService ownerService;
    private final OwnerAssembler ownerAssembler;
    
    public OwnerController(OwnerService ownerService, OwnerAssembler ownerAssembler) {
        this.ownerService = ownerService;
        this.ownerAssembler = ownerAssembler;
    }
    
    /**
     * Create a new owner
     * POST /api/masterdata/owners
     */
    @PostMapping
    public ApiResponse<OwnerResponse> createOwner(@Valid @RequestBody CreateOwnerRequest request) {
        Owner owner = ownerAssembler.toEntity(request);
        Owner created = ownerService.createOwner(owner);
        return ApiResponse.ok(ownerAssembler.toResponse(created));
    }
    
    /**
     * Update an existing owner
     * PUT /api/masterdata/owners/{id}
     */
    @PutMapping("/{id}")
    public ApiResponse<OwnerResponse> updateOwner(
            @PathVariable @Min(1) Long id,
            @Valid @RequestBody UpdateOwnerRequest request) {
        Owner owner = new Owner();
        ownerAssembler.updateEntity(owner, request);
        Owner updated = ownerService.updateOwner(id, owner);
        return ApiResponse.ok(ownerAssembler.toResponse(updated));
    }
    
    /**
     * Delete an owner (logical delete)
     * DELETE /api/masterdata/owners/{id}
     */
    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteOwner(@PathVariable @Min(1) Long id) {
        ownerService.deleteOwner(id);
        return ApiResponse.ok();
    }
    
    /**
     * Get owner by ID
     * GET /api/masterdata/owners/{id}
     */
    @GetMapping("/{id}")
    public ApiResponse<OwnerResponse> getOwner(@PathVariable @Min(1) Long id) {
        Owner owner = ownerService.getById(id);
        return ApiResponse.ok(ownerAssembler.toResponse(owner));
    }
    
    /**
     * Get paginated list of owners
     * GET /api/masterdata/owners?page=1&size=20
     */
    @GetMapping
    public ApiResponse<PageResponse<OwnerResponse>> getOwners(
            @RequestParam(defaultValue = "1") @Min(1) Integer page,
            @RequestParam(defaultValue = "20") @Min(1) Integer size) {
        
        Page<Owner> ownerPage = ownerService.getOwners(page, size);
        
        List<OwnerResponse> responses = ownerPage.getRecords().stream()
                .map(ownerAssembler::toResponse)
                .collect(Collectors.toList());
        
        PageResponse<OwnerResponse> pageResponse = new PageResponse<>(
                responses,
                ownerPage.getTotal(),
                (int) ownerPage.getCurrent(),
                (int) ownerPage.getSize()
        );
        
        return ApiResponse.ok(pageResponse);
    }
    
    /**
     * Search owners by code or name
     * GET /api/masterdata/owners/search?keyword=xxx&page=1&size=20
     */
    @GetMapping("/search")
    public ApiResponse<PageResponse<OwnerResponse>> searchOwners(
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") @Min(1) Integer page,
            @RequestParam(defaultValue = "20") @Min(1) Integer size) {
        
        Page<Owner> ownerPage = ownerService.searchOwners(keyword, page, size);
        
        List<OwnerResponse> responses = ownerPage.getRecords().stream()
                .map(ownerAssembler::toResponse)
                .collect(Collectors.toList());
        
        PageResponse<OwnerResponse> pageResponse = new PageResponse<>(
                responses,
                ownerPage.getTotal(),
                (int) ownerPage.getCurrent(),
                (int) ownerPage.getSize()
        );
        
        return ApiResponse.ok(pageResponse);
    }
}
