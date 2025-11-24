package com.example.wms.auth.domain.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.wms.auth.domain.entity.SysMenu;

import java.util.List;

public interface MenuService extends IService<SysMenu> {

    List<SysMenu> findByRoleIds(List<Long> roleIds);
}

