package com.example.wms.auth.domain.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.wms.auth.domain.entity.SysMenu;
import com.example.wms.auth.domain.mapper.SysMenuMapper;
import com.example.wms.auth.domain.service.MenuService;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class MenuServiceImpl extends ServiceImpl<SysMenuMapper, SysMenu> implements MenuService {

    @Override
    public List<SysMenu> findByRoleIds(List<Long> roleIds) {
        if (roleIds == null || roleIds.isEmpty()) {
            return Collections.emptyList();
        }
        String roleIdStr = roleIds.stream().map(String::valueOf).collect(Collectors.joining(","));
        return lambdaQuery()
                .inSql(SysMenu::getId, "select menu_id from sys_role_menu where role_id in (%s)".formatted(roleIdStr))
                .orderByAsc(SysMenu::getSort)
                .list();
    }
}

