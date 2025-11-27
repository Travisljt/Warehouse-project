package com.travislai.wms.auth.domain.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.travislai.wms.auth.domain.entity.SysUser;

import java.util.Optional;

public interface UserService extends IService<SysUser> {

    Optional<SysUser> findByUsername(String username);
}

