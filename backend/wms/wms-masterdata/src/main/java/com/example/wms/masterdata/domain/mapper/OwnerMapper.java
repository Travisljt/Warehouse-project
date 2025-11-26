package com.example.wms.masterdata.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.wms.masterdata.domain.entity.Owner;
import org.apache.ibatis.annotations.Mapper;

/**
 * Owner mapper interface
 * Provides CRUD operations for Owner entity
 */
@Mapper
public interface OwnerMapper extends BaseMapper<Owner> {
}
