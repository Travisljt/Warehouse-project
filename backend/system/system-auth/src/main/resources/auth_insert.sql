-- =============================================
-- Auth Service Default Data
-- =============================================
-- Description: Inserts default users, roles, menus and permissions
-- Service: system-auth
-- Date: 2025-11-27
-- =============================================

-- =============================================
-- Default Admin User
-- Username: admin
-- Password: admin (SHA-256 hashed)
-- =============================================
INSERT INTO sys_user (username, password, nickname, status)
VALUES ('admin', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', '系统管理员', 'ENABLED')
ON CONFLICT (username) DO NOTHING;

-- =============================================
-- Default Admin Role
-- =============================================
INSERT INTO sys_role (code, name)
VALUES ('ADMIN', '超级管理员')
ON CONFLICT (code) DO NOTHING;

-- =============================================
-- Assign Admin Role to Admin User
-- =============================================
INSERT INTO sys_user_role (user_id, role_id)
SELECT u.id, r.id
FROM sys_user u, sys_role r
WHERE u.username = 'admin'
  AND r.code = 'ADMIN'
  AND NOT EXISTS(
    SELECT 1 FROM sys_user_role sur 
    WHERE sur.user_id = u.id AND sur.role_id = r.id
  );

-- =============================================
-- Default Menu Items
-- =============================================
INSERT INTO sys_menu (id, parent_id, title, path, component, type, permission, sort, icon)
VALUES
    (1, 0, '运营驾驶舱', '/dashboard', 'DashboardView', 'MENU', 'dashboard:view', 1, 'dashboard'),
    (2, 0, '用户管理', '/users', 'UserListView', 'MENU', 'user:list', 2, 'user'),
    (3, 2, '角色管理', '/roles', 'RoleListView', 'MENU', 'role:list', 3, 'shield'),
    (4, 2, '菜单管理', '/menus', 'MenuListView', 'MENU', 'menu:list', 4, 'menu')
ON CONFLICT (id) DO NOTHING;

-- =============================================
-- Assign All Menus to Admin Role
-- =============================================
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT r.id, m.id
FROM sys_role r
JOIN sys_menu m ON m.id IN (1, 2, 3, 4)
WHERE r.code = 'ADMIN'
  AND NOT EXISTS(
    SELECT 1 FROM sys_role_menu srm 
    WHERE srm.role_id = r.id AND srm.menu_id = m.id
  );
