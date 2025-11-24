package com.example.wms.auth.domain.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.wms.auth.domain.entity.SysUser;
import com.example.wms.auth.domain.mapper.SysUserMapper;
import com.example.wms.auth.domain.service.UserService;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserServiceImpl extends ServiceImpl<SysUserMapper, SysUser> implements UserService {

    @Override
    public Optional<SysUser> findByUsername(String username) {
        return lambdaQuery().eq(SysUser::getUsername, username).oneOpt();
    }
}

