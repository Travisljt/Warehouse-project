package com.travislai.wms.auth.domain.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.travislai.wms.auth.domain.entity.SysRole;
import com.travislai.wms.auth.domain.mapper.SysRoleMapper;
import com.travislai.wms.auth.domain.service.RoleService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RoleServiceImpl extends ServiceImpl<SysRoleMapper, SysRole> implements RoleService {

    @Override
    public List<SysRole> findByUserId(Long userId) {
        return lambdaQuery()
                .inSql(SysRole::getId, "select role_id from sys_user_role where user_id = %d".formatted(userId))
                .list();
    }
}

