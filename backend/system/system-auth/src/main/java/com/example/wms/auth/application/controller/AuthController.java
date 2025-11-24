package com.example.wms.auth.application.controller;

import cn.dev33.satoken.secure.SaSecureUtil;
import cn.dev33.satoken.stp.StpUtil;
import com.example.wms.auth.application.assembler.MenuAssembler;
import com.example.wms.auth.application.dto.LoginRequest;
import com.example.wms.auth.application.dto.LoginResponse;
import com.example.wms.auth.application.dto.MenuNode;
import com.example.wms.auth.application.dto.UserProfileResponse;
import com.example.wms.auth.domain.entity.SysMenu;
import com.example.wms.auth.domain.entity.SysRole;
import com.example.wms.auth.domain.entity.SysUser;
import com.example.wms.auth.domain.service.MenuService;
import com.example.wms.auth.domain.service.RoleService;
import com.example.wms.auth.domain.service.UserService;
import com.example.wms.common.web.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserService userService;
    private final RoleService roleService;
    private final MenuService menuService;
    public AuthController(UserService userService,
                          RoleService roleService,
                          MenuService menuService) {
        this.userService = userService;
        this.roleService = roleService;
        this.menuService = menuService;
    }

    @PostMapping("/login")
    public ApiResponse<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        SysUser user = userService.findByUsername(request.username())
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
        String encoded = SaSecureUtil.sha256(request.password());
        if (!encoded.equals(user.getPassword())) {
            throw new IllegalArgumentException("用户名或密码错误");
        }
        if (!"ENABLED".equalsIgnoreCase(user.getStatus())) {
            throw new IllegalStateException("账号未启用");
        }
        StpUtil.login(user.getId());
        List<SysRole> roles = roleService.findByUserId(user.getId());
        List<String> roleCodes = roles.stream().map(SysRole::getCode).toList();
        return ApiResponse.ok(new LoginResponse(StpUtil.getTokenValue(), roleCodes, user.getNickname()));
    }

    @PostMapping("/logout")
    public ApiResponse<Void> logout() {
        StpUtil.logout();
        return ApiResponse.ok();
    }

    @GetMapping("/profile")
    public ApiResponse<UserProfileResponse> profile() {
        Long loginId = StpUtil.getLoginIdAsLong();
        SysUser user = userService.getById(loginId);
        List<SysRole> roles = roleService.findByUserId(loginId);
        List<String> roleCodes = roles.stream().map(SysRole::getCode).toList();
        List<String> permissions = menuService.findByRoleIds(roles.stream().map(SysRole::getId).toList())
                .stream().map(SysMenu::getPermission).filter(p -> p != null && !p.isBlank()).toList();
        return ApiResponse.ok(new UserProfileResponse(user.getId(), user.getUsername(),
                user.getNickname(), roleCodes, permissions));
    }

    @GetMapping("/menus")
    public ApiResponse<List<MenuNode>> menus() {
        Long loginId = StpUtil.getLoginIdAsLong();
        List<Long> roleIds = roleService.findByUserId(loginId).stream().map(SysRole::getId).toList();
        List<SysMenu> menus = menuService.findByRoleIds(roleIds);
        return ApiResponse.ok(MenuAssembler.buildTree(menus));
    }
}

