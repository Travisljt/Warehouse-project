package com.example.wms.auth.domain.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.wms.auth.domain.entity.SysRole;

import java.util.List;

public interface RoleService extends IService<SysRole> {

    List<SysRole> findByUserId(Long userId);
}

